import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/meeting.dart';
import '../../domain/repositories/meeting_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/meeting_remote_data_source.dart';

@LazySingleton(as: MeetingRepository)
class MeetingRepositoryImpl implements MeetingRepository {
  final MeetingRemoteDataSource remoteDataSource;
  final AuthRemoteDataSource authRemoteDataSource;
  final NetworkInfo networkInfo;

  MeetingRepositoryImpl({
    required this.remoteDataSource,
    required this.authRemoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Meeting>> createMeeting({
    required String title,
    required String description,
    required DateTime scheduledAt,
    required int durationInMinutes,
    String? password,
    bool isRecordingEnabled = false,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final currentUser = await authRemoteDataSource.getCurrentUser();
        if (currentUser == null) {
          return const Left(AuthFailure('User not authenticated'));
        }

        final meeting = await remoteDataSource.createMeeting(
          title: title,
          description: description,
          hostId: currentUser.id,
          hostName: currentUser.name,
          scheduledAt: scheduledAt,
          durationInMinutes: durationInMinutes,
          password: password,
          isRecordingEnabled: isRecordingEnabled,
        );
        return Right(meeting);
      } on MeetingException catch (e) {
        return Left(MeetingFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Meeting>> getMeeting({
    required String meetingId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final meeting = await remoteDataSource.getMeeting(meetingId: meetingId);
        return Right(meeting);
      } on MeetingException catch (e) {
        return Left(MeetingFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<Meeting>>> getUserMeetings({
    required String userId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final meetings = await remoteDataSource.getUserMeetings(userId: userId);
        return Right(meetings);
      } on MeetingException catch (e) {
        return Left(MeetingFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Meeting>> joinMeeting({
    required String meetingId,
    String? password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final currentUser = await authRemoteDataSource.getCurrentUser();
        if (currentUser == null) {
          return const Left(AuthFailure('User not authenticated'));
        }

        final meeting = await remoteDataSource.joinMeeting(
          meetingId: meetingId,
          userId: currentUser.id,
          password: password,
        );
        return Right(meeting);
      } on MeetingException catch (e) {
        return Left(MeetingFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> leaveMeeting({
    required String meetingId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final currentUser = await authRemoteDataSource.getCurrentUser();
        if (currentUser == null) {
          return const Left(AuthFailure('User not authenticated'));
        }

        await remoteDataSource.leaveMeeting(
          meetingId: meetingId,
          userId: currentUser.id,
        );
        return const Right(null);
      } on MeetingException catch (e) {
        return Left(MeetingFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Meeting>> updateMeeting({
    required String meetingId,
    String? title,
    String? description,
    DateTime? scheduledAt,
    int? durationInMinutes,
    String? password,
    bool? isRecordingEnabled,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final meeting = await remoteDataSource.updateMeeting(
          meetingId: meetingId,
          title: title,
          description: description,
          scheduledAt: scheduledAt,
          durationInMinutes: durationInMinutes,
          password: password,
          isRecordingEnabled: isRecordingEnabled,
        );
        return Right(meeting);
      } on MeetingException catch (e) {
        return Left(MeetingFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMeeting({
    required String meetingId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteMeeting(meetingId: meetingId);
        return const Right(null);
      } on MeetingException catch (e) {
        return Left(MeetingFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> endMeeting({required String meetingId}) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.endMeeting(meetingId: meetingId);
        return const Right(null);
      } on MeetingException catch (e) {
        return Left(MeetingFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Stream<Meeting> watchMeeting({required String meetingId}) {
    return remoteDataSource.watchMeeting(meetingId: meetingId);
  }
}
