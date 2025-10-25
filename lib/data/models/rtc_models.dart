import '../../domain/entities/rtc_entities.dart';

class RTCParticipantModel extends RTCParticipant {
  const RTCParticipantModel({
    required super.id,
    required super.name,
    required super.email,
    required super.isAudioOn,
    required super.isVideoOn,
    required super.isHost,
    required super.joinedAt,
    super.streamId,
  });

  factory RTCParticipantModel.fromJson(Map<String, dynamic> json) {
    return RTCParticipantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      isAudioOn: json['isAudioOn'] as bool,
      isVideoOn: json['isVideoOn'] as bool,
      isHost: json['isHost'] as bool,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      streamId: json['streamId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isAudioOn': isAudioOn,
      'isVideoOn': isVideoOn,
      'isHost': isHost,
      'joinedAt': joinedAt.toIso8601String(),
      'streamId': streamId,
    };
  }

  factory RTCParticipantModel.fromEntity(RTCParticipant participant) {
    return RTCParticipantModel(
      id: participant.id,
      name: participant.name,
      email: participant.email,
      isAudioOn: participant.isAudioOn,
      isVideoOn: participant.isVideoOn,
      isHost: participant.isHost,
      joinedAt: participant.joinedAt,
      streamId: participant.streamId,
    );
  }
}

class SignalingMessageModel extends SignalingMessage {
  const SignalingMessageModel({
    required super.from,
    required super.to,
    required super.type,
    required super.data,
    required super.timestamp,
  });

  factory SignalingMessageModel.fromJson(Map<String, dynamic> json) {
    return SignalingMessageModel(
      from: json['from'] as String,
      to: json['to'] as String,
      type: json['type'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'type': type,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SignalingMessageModel.fromEntity(SignalingMessage message) {
    return SignalingMessageModel(
      from: message.from,
      to: message.to,
      type: message.type,
      data: message.data,
      timestamp: message.timestamp,
    );
  }
}
