import 'package:equatable/equatable.dart';

import '../../../domain/entities/rtc_entities.dart';

abstract class WebRTCEvent extends Equatable {
  const WebRTCEvent();

  @override
  List<Object?> get props => [];
}

class InitializeWebRTCEvent extends WebRTCEvent {
  const InitializeWebRTCEvent();
}

class JoinRoomEvent extends WebRTCEvent {
  final String roomId;
  final String userId;

  const JoinRoomEvent({required this.roomId, required this.userId});

  @override
  List<Object> get props => [roomId, userId];
}

class LeaveRoomEvent extends WebRTCEvent {
  final String roomId;
  final String userId;

  const LeaveRoomEvent({required this.roomId, required this.userId});

  @override
  List<Object> get props => [roomId, userId];
}

class SendSignalingMessageEvent extends WebRTCEvent {
  final String roomId;
  final SignalingMessage message;

  const SendSignalingMessageEvent({
    required this.roomId,
    required this.message,
  });

  @override
  List<Object> get props => [roomId, message];
}

class ToggleAudioEvent extends WebRTCEvent {
  const ToggleAudioEvent();
}

class ToggleVideoEvent extends WebRTCEvent {
  const ToggleVideoEvent();
}

class ParticipantsUpdatedEvent extends WebRTCEvent {
  final List<RTCParticipant> participants;

  const ParticipantsUpdatedEvent(this.participants);

  @override
  List<Object> get props => [participants];
}

class SignalingMessageReceivedEvent extends WebRTCEvent {
  final SignalingMessage message;

  const SignalingMessageReceivedEvent(this.message);

  @override
  List<Object> get props => [message];
}

class UpdateParticipantStatusEvent extends WebRTCEvent {
  final String roomId;
  final String userId;
  final bool isAudioOn;
  final bool isVideoOn;

  const UpdateParticipantStatusEvent({
    required this.roomId,
    required this.userId,
    required this.isAudioOn,
    required this.isVideoOn,
  });

  @override
  List<Object> get props => [roomId, userId, isAudioOn, isVideoOn];
}

class DisposeWebRTCEvent extends WebRTCEvent {
  const DisposeWebRTCEvent();
}
