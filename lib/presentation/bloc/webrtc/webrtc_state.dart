import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;

import '../../../domain/entities/rtc_entities.dart';

abstract class WebRTCState extends Equatable {
  const WebRTCState();

  @override
  List<Object?> get props => [];
}

class WebRTCInitial extends WebRTCState {
  const WebRTCInitial();
}

class WebRTCLoading extends WebRTCState {
  const WebRTCLoading();
}

class WebRTCInitialized extends WebRTCState {
  final webrtc.MediaStream? localStream;

  const WebRTCInitialized({this.localStream});

  @override
  List<Object?> get props => [localStream];
}

class WebRTCRoomJoined extends WebRTCState {
  final String roomId;
  final String userId;
  final webrtc.MediaStream? localStream;
  final Map<String, webrtc.MediaStream> remoteStreams;
  final List<RTCParticipant> participants;
  final bool isAudioEnabled;
  final bool isVideoEnabled;

  const WebRTCRoomJoined({
    required this.roomId,
    required this.userId,
    this.localStream,
    this.remoteStreams = const {},
    this.participants = const [],
    this.isAudioEnabled = true,
    this.isVideoEnabled = true,
  });

  WebRTCRoomJoined copyWith({
    String? roomId,
    String? userId,
    webrtc.MediaStream? localStream,
    Map<String, webrtc.MediaStream>? remoteStreams,
    List<RTCParticipant>? participants,
    bool? isAudioEnabled,
    bool? isVideoEnabled,
  }) {
    return WebRTCRoomJoined(
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      localStream: localStream ?? this.localStream,
      remoteStreams: remoteStreams ?? this.remoteStreams,
      participants: participants ?? this.participants,
      isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
    );
  }

  @override
  List<Object?> get props => [
    roomId,
    userId,
    localStream,
    remoteStreams,
    participants,
    isAudioEnabled,
    isVideoEnabled,
  ];
}

class WebRTCError extends WebRTCState {
  final String message;

  const WebRTCError(this.message);

  @override
  List<Object> get props => [message];
}

class WebRTCDisposed extends WebRTCState {
  const WebRTCDisposed();
}
