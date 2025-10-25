import 'package:dartz/dartz.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/rtc_entities.dart';
import '../../domain/repositories/webrtc_repository.dart';
import '../datasources/webrtc_remote_data_source.dart';
import '../models/rtc_models.dart';

class WebRTCRepositoryImpl implements WebRTCRepository {
  final WebRTCRemoteDataSource remoteDataSource;

  WebRTCRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, webrtc.MediaStream>> initializeWebRTC() async {
    try {
      final result = await remoteDataSource.initializeWebRTC();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to initialize WebRTC: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> joinRoom(String roomId, String userId) async {
    try {
      final participantModel = RTCParticipantModel(
        id: userId,
        name: 'User $userId', // Default name, can be customized later
        email: '', // Can be fetched from user context
        isHost: false, // Default non-host
        isAudioOn: true,
        isVideoOn: true,
        joinedAt: DateTime.now(),
      );
      await remoteDataSource.joinRoom(roomId, participantModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to join room: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> leaveRoom(String roomId, String userId) async {
    try {
      await remoteDataSource.leaveRoom(roomId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to leave room: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendSignalingMessage(
    String roomId,
    SignalingMessage message,
  ) async {
    try {
      final messageModel = SignalingMessageModel(
        from: message.from,
        to: message.to,
        type: message.type,
        data: message.data,
        timestamp: DateTime.now(),
      );
      await remoteDataSource.sendSignalingMessage(roomId, messageModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to send signaling message: $e'));
    }
  }

  @override
  Stream<SignalingMessage> listenToSignalingMessages(
    String roomId,
    String userId,
  ) {
    return remoteDataSource
        .listenToSignalingMessages(roomId, userId)
        .map((message) => message as SignalingMessage);
  }

  @override
  Stream<List<RTCParticipant>> listenToParticipants(String roomId) {
    return remoteDataSource
        .listenToParticipants(roomId)
        .map((participants) => participants.cast<RTCParticipant>());
  }

  @override
  Future<Either<Failure, void>> updateParticipantStatus(
    String roomId,
    String userId,
    bool isAudioOn,
    bool isVideoOn,
  ) async {
    try {
      await remoteDataSource.updateParticipantStatus(
        roomId,
        userId,
        isAudioOn,
        isVideoOn,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update participant status: $e'));
    }
  }

  @override
  Future<Either<Failure, webrtc.RTCPeerConnection>>
  createPeerConnection() async {
    try {
      final result = await remoteDataSource.createPeerConnection();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to create peer connection: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleAudio() async {
    try {
      await remoteDataSource.toggleAudio();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to toggle audio: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleVideo() async {
    try {
      await remoteDataSource.toggleVideo();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to toggle video: $e'));
    }
  }

  @override
  webrtc.MediaStream? get localStream => remoteDataSource.localStream;

  @override
  Map<String, webrtc.MediaStream> get remoteStreams =>
      remoteDataSource.remoteStreams;

  @override
  Future<Either<Failure, void>> dispose() async {
    try {
      await remoteDataSource.dispose();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to dispose WebRTC: $e'));
    }
  }
}
