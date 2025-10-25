import '../../domain/entities/meeting.dart';

class MeetingModel extends Meeting {
  const MeetingModel({
    required super.id,
    required super.title,
    required super.description,
    required super.hostId,
    required super.hostName,
    required super.scheduledAt,
    required super.durationInMinutes,
    required super.status,
    required super.participantIds,
    super.password,
    required super.isRecordingEnabled,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      hostId: json['hostId'] as String,
      hostName: json['hostName'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      durationInMinutes: json['durationInMinutes'] as int,
      status: MeetingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MeetingStatus.scheduled,
      ),
      participantIds: List<String>.from(json['participantIds'] ?? []),
      password: json['password'] as String?,
      isRecordingEnabled: json['isRecordingEnabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'hostId': hostId,
      'hostName': hostName,
      'scheduledAt': scheduledAt.toIso8601String(),
      'durationInMinutes': durationInMinutes,
      'status': status.name,
      'participantIds': participantIds,
      'password': password,
      'isRecordingEnabled': isRecordingEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MeetingModel.fromEntity(Meeting meeting) {
    return MeetingModel(
      id: meeting.id,
      title: meeting.title,
      description: meeting.description,
      hostId: meeting.hostId,
      hostName: meeting.hostName,
      scheduledAt: meeting.scheduledAt,
      durationInMinutes: meeting.durationInMinutes,
      status: meeting.status,
      participantIds: meeting.participantIds,
      password: meeting.password,
      isRecordingEnabled: meeting.isRecordingEnabled,
      createdAt: meeting.createdAt,
      updatedAt: meeting.updatedAt,
    );
  }

  @override
  MeetingModel copyWith({
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
    return MeetingModel(
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
