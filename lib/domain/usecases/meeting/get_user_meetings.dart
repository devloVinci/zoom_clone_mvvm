import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../entities/meeting.dart';
import '../../repositories/meeting_repository.dart';
import '../usecase.dart';

@injectable
class GetUserMeetings implements UseCase<List<Meeting>, GetUserMeetingsParams> {
  final MeetingRepository repository;

  GetUserMeetings(this.repository);

  @override
  Future<Either<Failure, List<Meeting>>> call(
    GetUserMeetingsParams params,
  ) async {
    return await repository.getUserMeetings(userId: params.userId);
  }
}

class GetUserMeetingsParams extends Equatable {
  final String userId;

  const GetUserMeetingsParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
