part of 'meeting_bloc.dart';

enum MeetingStatus { initial, loading, success, error }

class MeetingState extends Equatable {
  final MeetingStatus status;
  final Meeting? currentMeeting;
  final List<Meeting> userMeetings;
  final String? errorMessage;

  const MeetingState({
    this.status = MeetingStatus.initial,
    this.currentMeeting,
    this.userMeetings = const [],
    this.errorMessage,
  });

  MeetingState copyWith({
    MeetingStatus? status,
    Meeting? currentMeeting,
    List<Meeting>? userMeetings,
    String? errorMessage,
  }) {
    return MeetingState(
      status: status ?? this.status,
      currentMeeting: currentMeeting ?? this.currentMeeting,
      userMeetings: userMeetings ?? this.userMeetings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentMeeting,
    userMeetings,
    errorMessage,
  ];
}
