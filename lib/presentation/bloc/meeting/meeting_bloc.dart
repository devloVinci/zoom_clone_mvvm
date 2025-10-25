import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/meeting.dart';
import '../../../domain/usecases/meeting/create_meeting.dart';
import '../../../domain/usecases/meeting/get_user_meetings.dart';
import '../../../domain/usecases/meeting/join_meeting.dart';

part 'meeting_event.dart';
part 'meeting_state.dart';

@injectable
class MeetingBloc extends Bloc<MeetingEvent, MeetingState> {
  final CreateMeeting _createMeeting;
  final JoinMeeting _joinMeeting;
  final GetUserMeetings _getUserMeetings;

  MeetingBloc(this._createMeeting, this._joinMeeting, this._getUserMeetings)
    : super(const MeetingState()) {
    on<MeetingCreateRequested>(_onMeetingCreateRequested);
    on<MeetingJoinRequested>(_onMeetingJoinRequested);
    on<MeetingLoadUserMeetings>(_onMeetingLoadUserMeetings);
  }

  Future<void> _onMeetingCreateRequested(
    MeetingCreateRequested event,
    Emitter<MeetingState> emit,
  ) async {
    emit(state.copyWith(status: MeetingStatus.loading));

    final result = await _createMeeting(
      CreateMeetingParams(
        title: event.title,
        description: event.description,
        scheduledAt: event.scheduledAt,
        durationInMinutes: event.durationInMinutes,
        password: event.password,
        isRecordingEnabled: event.isRecordingEnabled,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MeetingStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (meeting) => emit(
        state.copyWith(status: MeetingStatus.success, currentMeeting: meeting),
      ),
    );
  }

  Future<void> _onMeetingJoinRequested(
    MeetingJoinRequested event,
    Emitter<MeetingState> emit,
  ) async {
    emit(state.copyWith(status: MeetingStatus.loading));

    final result = await _joinMeeting(
      JoinMeetingParams(meetingId: event.meetingId, password: event.password),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MeetingStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (meeting) => emit(
        state.copyWith(status: MeetingStatus.success, currentMeeting: meeting),
      ),
    );
  }

  Future<void> _onMeetingLoadUserMeetings(
    MeetingLoadUserMeetings event,
    Emitter<MeetingState> emit,
  ) async {
    emit(state.copyWith(status: MeetingStatus.loading));

    final result = await _getUserMeetings(
      GetUserMeetingsParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MeetingStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (meetings) => emit(
        state.copyWith(status: MeetingStatus.success, userMeetings: meetings),
      ),
    );
  }
}
