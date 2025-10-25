import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../entities/meeting.dart';
import '../../repositories/meeting_repository.dart';
import '../usecase.dart';

@injectable
class JoinMeeting implements UseCase<Meeting, JoinMeetingParams> {
  final MeetingRepository repository;

  JoinMeeting(this.repository);

  @override
  Future<Either<Failure, Meeting>> call(JoinMeetingParams params) async {
    return await repository.joinMeeting(
      meetingId: params.meetingId,
      password: params.password,
    );
  }
}

class JoinMeetingParams extends Equatable {
  final String meetingId;
  final String? password;

  const JoinMeetingParams({required this.meetingId, this.password});

  @override
  List<Object?> get props => [meetingId, password];
}
