import 'package:dartz/dartz.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;

import '../entities/rtc_entities.dart';
import '../../core/error/failures.dart';

abstract class WebRTCRepository {
  /// Initialize WebRTC and get local stream
  Future<Either<Failure, webrtc.MediaStream>> initializeWebRTC();

  /// Join a room and start signaling
  Future<Either<Failure, void>> joinRoom(String roomId, String userId);

  /// Leave the room and cleanup connections
  Future<Either<Failure, void>> leaveRoom(String roomId, String userId);

  /// Send signaling message (offer, answer, ICE candidate)
  Future<Either<Failure, void>> sendSignalingMessage(
    String roomId,
    SignalingMessage message,
  );

  /// Listen to signaling messages
  Stream<SignalingMessage> listenToSignalingMessages(
    String roomId,
    String userId,
  );

  /// Listen to room participants
  Stream<List<RTCParticipant>> listenToParticipants(String roomId);

  /// Update participant status (audio/video)
  Future<Either<Failure, void>> updateParticipantStatus(
    String roomId,
    String userId,
    bool isAudioOn,
    bool isVideoOn,
  );

  /// Create peer connection
  Future<Either<Failure, webrtc.RTCPeerConnection>> createPeerConnection();

  /// Toggle local audio
  Future<Either<Failure, void>> toggleAudio();

  /// Toggle local video
  Future<Either<Failure, void>> toggleVideo();

  /// Get local stream
  webrtc.MediaStream? get localStream;

  /// Get remote streams
  Map<String, webrtc.MediaStream> get remoteStreams;

  /// Dispose resources
  Future<void> dispose();
}
