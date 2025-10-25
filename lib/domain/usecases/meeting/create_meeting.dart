import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../entities/meeting.dart';
import '../../repositories/meeting_repository.dart';
import '../usecase.dart';

@injectable
class CreateMeeting implements UseCase<Meeting, CreateMeetingParams> {
  final MeetingRepository repository;

  CreateMeeting(this.repository);

  @override
  Future<Either<Failure, Meeting>> call(CreateMeetingParams params) async {
    return await repository.createMeeting(
      title: params.title,
      description: params.description,
      scheduledAt: params.scheduledAt,
      durationInMinutes: params.durationInMinutes,
      password: params.password,
      isRecordingEnabled: params.isRecordingEnabled,
    );
  }
}

class CreateMeetingParams extends Equatable {
  final String title;
  final String description;
  final DateTime scheduledAt;
  final int durationInMinutes;
  final String? password;
  final bool isRecordingEnabled;

  const CreateMeetingParams({
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
