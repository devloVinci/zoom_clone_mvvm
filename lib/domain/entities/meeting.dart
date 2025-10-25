import 'package:equatable/equatable.dart';

enum MeetingStatus { scheduled, active, ended, cancelled }

class Meeting extends Equatable {
  final String id;
  final String title;
  final String description;
  final String hostId;
  final String hostName;
  final DateTime scheduledAt;
  final int durationInMinutes;
  final MeetingStatus status;
  final List<String> participantIds;
  final String? password;
  final bool isRecordingEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Meeting({
    required this.id,
    required this.title,
    required this.description,
    required this.hostId,
    required this.hostName,
    required this.scheduledAt,
    required this.durationInMinutes,
    required this.status,
    required this.participantIds,
    this.password,
    required this.isRecordingEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    hostId,
    hostName,
    scheduledAt,
    durationInMinutes,
    status,
    participantIds,
    password,
    isRecordingEnabled,
    createdAt,
    updatedAt,
  ];

  Meeting copyWith({
    String? id,
    String? title,
    String? description,
    String? hostId,
    String? hostName,
    DateTime? scheduledAt,
    int? durationInMinutes,
    MeetingStatus? status,
    List<String>? participantIds,
    String? password,
    bool? isRecordingEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Meeting(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationInMinutes: durationInMinutes ?? this.durationInMinutes,
      status: status ?? this.status,
      participantIds: participantIds ?? this.participantIds,
      password: password ?? this.password,
      isRecordingEnabled: isRecordingEnabled ?? this.isRecordingEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
