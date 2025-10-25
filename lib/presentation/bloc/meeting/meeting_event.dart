part of 'meeting_bloc.dart';

abstract class MeetingEvent extends Equatable {
  const MeetingEvent();

  @override
  List<Object?> get props => [];
}

class MeetingCreateRequested extends MeetingEvent {
  final String title;
  final String description;
  final DateTime scheduledAt;
  final int durationInMinutes;
  final String? password;
  final bool isRecordingEnabled;

  const MeetingCreateRequested({
    required this.title,
    required this.description,
    required this.scheduledAt,
    required this.durationInMinutes,
    this.password,
    this.isRecordingEnabled = false,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    scheduledAt,
    durationInMinutes,
    password,
    isRecordingEnabled,
  ];
}

class MeetingJoinRequested extends MeetingEvent {
  final String meetingId;
  final String? password;

  const MeetingJoinRequested({required this.meetingId, this.password});

  @override
  List<Object?> get props => [meetingId, password];
}

class MeetingLeaveRequested extends MeetingEvent {
  final String meetingId;

  const MeetingLeaveRequested({required this.meetingId});

  @override
  List<Object> get props => [meetingId];
}

class MeetingLoadUserMeetings extends MeetingEvent {
  final String userId;

  const MeetingLoadUserMeetings({required this.userId});

  @override
  List<Object> get props => [userId];
}
