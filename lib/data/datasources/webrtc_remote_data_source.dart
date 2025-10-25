import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:permission_handler/permission_handler.dart';

import '../../core/error/exceptions.dart';
import '../models/rtc_models.dart';

abstract class WebRTCRemoteDataSource {
  Future<webrtc.MediaStream> initializeWebRTC();
  Future<void> joinRoom(String roomId, RTCParticipantModel participant);
  Future<void> leaveRoom(String roomId, String userId);
  Future<void> sendSignalingMessage(
    String roomId,
    SignalingMessageModel message,
  );
  Stream<SignalingMessageModel> listenToSignalingMessages(
    String roomId,
    String userId,
  );
  Stream<List<RTCParticipantModel>> listenToParticipants(String roomId);
  Future<void> updateParticipantStatus(
    String roomId,
    String userId,
    bool isAudioOn,
    bool isVideoOn,
  );
  Future<webrtc.RTCPeerConnection> createPeerConnection();
  Future<void> toggleAudio();
  Future<void> toggleVideo();
  webrtc.MediaStream? get localStream;
  Map<String, webrtc.MediaStream> get remoteStreams;
  Future<void> dispose();
}

class WebRTCRemoteDataSourceImpl implements WebRTCRemoteDataSource {
  final FirebaseFirestore firestore;

  webrtc.MediaStream? _localStream;
  final Map<String, webrtc.MediaStream> _remoteStreams = {};
  final Map<String, webrtc.RTCPeerConnection> _peerConnections = {};
  bool _isAudioEnabled = true;
  bool _isVideoEnabled = true;

  WebRTCRemoteDataSourceImpl({required this.firestore});

  @override
  webrtc.MediaStream? get localStream => _localStream;

  @override
  Map<String, webrtc.MediaStream> get remoteStreams =>
      Map.unmodifiable(_remoteStreams);

  @override
  Future<webrtc.MediaStream> initializeWebRTC() async {
    try {
      // Request permissions
      await _requestPermissions();

      // Get user media
      final constraints = {
        'audio': true,
        'video': {
          'mandatory': {
            'minWidth': '640',
            'minHeight': '480',
            'minFrameRate': '30',
          },
          'facingMode': 'user',
          'optional': [],
        },
      };

      _localStream = await webrtc.navigator.mediaDevices.getUserMedia(
        constraints,
      );
      // Debug: log local tracks
      try {
        print('initializeWebRTC: localStream id=${_localStream?.id}');
        if (_localStream != null) {
          print(
            '  audioTracks=${_localStream!.getAudioTracks().map((t) => t.id).toList()}',
          );
          print(
            '  videoTracks=${_localStream!.getVideoTracks().map((t) => t.id).toList()}',
          );
        }
      } catch (_) {}
      return _localStream!;
    } catch (e) {
      throw ServerException('Failed to initialize WebRTC: $e');
    }
  }

  Future<void> _requestPermissions() async {
    final permissions = [Permission.camera, Permission.microphone];

    for (final permission in permissions) {
      final status = await permission.request();
      if (!status.isGranted) {
        throw ServerException(
          'Permission ${permission.toString()} not granted',
        );
      }
    }
  }

  @override
  Future<webrtc.RTCPeerConnection> createPeerConnection() async {
    try {
      final configuration = <String, dynamic>{
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:stun1.l.google.com:19302'},
        ],
      };

      final peerConnection = await webrtc.createPeerConnection(configuration);

      // Peer connection logging and handlers
      peerConnection.onIceCandidate = (candidate) {
        try {
          print(
            'onIceCandidate: ${candidate.candidate} sdpMid=${candidate.sdpMid} sdpMLineIndex=${candidate.sdpMLineIndex}',
          );
        } catch (_) {}
      };

      peerConnection.onIceConnectionState = (state) {
        print('onIceConnectionState: $state');
      };

      peerConnection.onConnectionState = (state) {
        print('onConnectionState: $state');
      };

      peerConnection.onSignalingState = (state) {
        print('onSignalingState: $state');
      };

      // Newer API: onTrack
      peerConnection.onTrack = (webrtc.RTCTrackEvent event) {
        try {
          print(
            'onTrack: kind=${event.track.kind}, streams=${event.streams.map((s) => s.id).toList()}',
          );
          if (event.streams.isNotEmpty) {
            final remote = event.streams[0];
            _remoteStreams[remote.id] = remote;
            print(
              '  -> added remote stream id=${remote.id} audio=${remote.getAudioTracks().map((t) => t.id).toList()}',
            );
          }
        } catch (e) {
          print('onTrack handler error: $e');
        }
      };

      // Older API: onAddStream fallback
      peerConnection.onAddStream = (webrtc.MediaStream stream) {
        try {
          print(
            'onAddStream: id=${stream.id} audio=${stream.getAudioTracks().map((t) => t.id).toList()}',
          );
          _remoteStreams[stream.id] = stream;
        } catch (e) {
          print('onAddStream handler error: $e');
        }
      };

      // Add local stream tracks
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) {
          peerConnection.addTrack(track, _localStream!);
          try {
            print(
              'createPeerConnection: added local track id=${track.id} kind=${track.kind}',
            );
          } catch (_) {}
        });
      }

      // Store temporarily in map using peerConnection.hashCode as key so dispose can close it
      _peerConnections['pc_${peerConnection.hashCode}'] = peerConnection;

      return peerConnection;
    } catch (e) {
      throw ServerException('Failed to create peer connection: $e');
    }
  }

  @override
  Future<void> joinRoom(String roomId, RTCParticipantModel participant) async {
    try {
      await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(participant.id)
          .set(participant.toJson());
    } catch (e) {
      throw ServerException('Failed to join room: $e');
    }
  }

  @override
  Future<void> leaveRoom(String roomId, String userId) async {
    try {
      await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(userId)
          .delete();
    } catch (e) {
      throw ServerException('Failed to leave room: $e');
    }
  }

  @override
  Future<void> sendSignalingMessage(
    String roomId,
    SignalingMessageModel message,
  ) async {
    try {
      await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('signaling')
          .add(message.toJson());
    } catch (e) {
      throw ServerException('Failed to send signaling message: $e');
    }
  }

  @override
  Stream<SignalingMessageModel> listenToSignalingMessages(
    String roomId,
    String userId,
  ) {
    return firestore
        .collection('rooms')
        .doc(roomId)
        .collection('signaling')
        .where('to', isEqualTo: userId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .expand((snapshot) => snapshot.docChanges)
        .where((change) => change.type == DocumentChangeType.added)
        .map(
          (change) => SignalingMessageModel.fromJson(
            change.doc.data() as Map<String, dynamic>,
          ),
        );
  }

  @override
  Stream<List<RTCParticipantModel>> listenToParticipants(String roomId) {
    return firestore
        .collection('rooms')
        .doc(roomId)
        .collection('participants')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RTCParticipantModel.fromJson(doc.data()))
              .toList(),
        );
  }

  @override
  Future<void> updateParticipantStatus(
    String roomId,
    String userId,
    bool isAudioOn,
    bool isVideoOn,
  ) async {
    try {
      await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(userId)
          .update({'isAudioOn': isAudioOn, 'isVideoOn': isVideoOn});
    } catch (e) {
      throw ServerException('Failed to update participant status: $e');
    }
  }

  @override
  Future<void> toggleAudio() async {
    try {
      if (_localStream != null) {
        final audioTracks = _localStream!.getAudioTracks();
        for (final track in audioTracks) {
          track.enabled = !track.enabled;
        }
        _isAudioEnabled = !_isAudioEnabled;
        print('toggleAudio: now=$_isAudioEnabled');
      }
    } catch (e) {
      throw ServerException('Failed to toggle audio: $e');
    }
  }

  @override
  Future<void> toggleVideo() async {
    try {
      if (_localStream != null) {
        final videoTracks = _localStream!.getVideoTracks();
        for (final track in videoTracks) {
          track.enabled = !track.enabled;
        }
        _isVideoEnabled = !_isVideoEnabled;
        print('toggleVideo: now=$_isVideoEnabled');
      }
    } catch (e) {
      throw ServerException('Failed to toggle video: $e');
    }
  }

  @override
  Future<void> dispose() async {
    try {
      // Close all peer connections
      for (final peerConnection in _peerConnections.values) {
        await peerConnection.close();
      }
      _peerConnections.clear();

      // Stop local stream
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) => track.stop());
        await _localStream!.dispose();
        _localStream = null;
      }

      // Stop remote streams
      for (final stream in _remoteStreams.values) {
        stream.getTracks().forEach((track) => track.stop());
        await stream.dispose();
      }
      print(
        'dispose: cleared remote and local streams and closed peer connections',
      );
      _remoteStreams.clear();
    } catch (e) {
      print('Error disposing WebRTC resources: $e');
    }
  }
}
