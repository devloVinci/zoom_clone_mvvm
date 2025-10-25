import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/meeting.dart';

abstract class MeetingRepository {
  Future<Either<Failure, Meeting>> createMeeting({
    required String title,
    required String description,
    required DateTime scheduledAt,
    required int durationInMinutes,
    String? password,
    bool isRecordingEnabled = false,
  });

  Future<Either<Failure, Meeting>> getMeeting({required String meetingId});

  Future<Either<Failure, List<Meeting>>> getUserMeetings({
    required String userId,
  });

  Future<Either<Failure, Meeting>> joinMeeting({
    required String meetingId,
    String? password,
  });

  Future<Either<Failure, void>> leaveMeeting({required String meetingId});

  Future<Either<Failure, Meeting>> updateMeeting({
    required String meetingId,
    String? title,
    String? description,
    DateTime? scheduledAt,
    int? durationInMinutes,
    String? password,
    bool? isRecordingEnabled,
  });

  Future<Either<Failure, void>> deleteMeeting({required String meetingId});

  Future<Either<Failure, void>> endMeeting({required String meetingId});

  Stream<Meeting> watchMeeting({required String meetingId});
}
