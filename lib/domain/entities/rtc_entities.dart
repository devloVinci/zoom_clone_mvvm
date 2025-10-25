import 'package:equatable/equatable.dart';

class RTCParticipant extends Equatable {
  final String id;
  final String name;
  final String email;
  final bool isAudioOn;
  final bool isVideoOn;
  final bool isHost;
  final DateTime joinedAt;
  final String? streamId;

  const RTCParticipant({
    required this.id,
    required this.name,
    required this.email,
    required this.isAudioOn,
    required this.isVideoOn,
    required this.isHost,
    required this.joinedAt,
    this.streamId,
  });

  RTCParticipant copyWith({
    String? id,
    String? name,
    String? email,
    bool? isAudioOn,
    bool? isVideoOn,
    bool? isHost,
    DateTime? joinedAt,
    String? streamId,
  }) {
    return RTCParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isAudioOn: isAudioOn ?? this.isAudioOn,
      isVideoOn: isVideoOn ?? this.isVideoOn,
      isHost: isHost ?? this.isHost,
      joinedAt: joinedAt ?? this.joinedAt,
      streamId: streamId ?? this.streamId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    isAudioOn,
    isVideoOn,
    isHost,
    joinedAt,
    streamId,
  ];
}

class SignalingMessage extends Equatable {
  final String from;
  final String to;
  final String type; // offer, answer, ice-candidate
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const SignalingMessage({
    required this.from,
    required this.to,
    required this.type,
    required this.data,
    required this.timestamp,
  });

  @override
  List<Object> get props => [from, to, type, data, timestamp];
}
