import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/webrtc_repository.dart';
import '../../entities/rtc_entities.dart';

class InitializeWebRTC implements UseCase<webrtc.MediaStream, NoParams> {
  final WebRTCRepository repository;

  InitializeWebRTC(this.repository);

  @override
  Future<Either<Failure, webrtc.MediaStream>> call(NoParams params) async {
    return await repository.initializeWebRTC();
  }
}

class JoinRoom implements UseCase<void, JoinRoomParams> {
  final WebRTCRepository repository;

  JoinRoom(this.repository);

  @override
  Future<Either<Failure, void>> call(JoinRoomParams params) async {
    return await repository.joinRoom(params.roomId, params.userId);
  }
}

class LeaveRoom implements UseCase<void, LeaveRoomParams> {
  final WebRTCRepository repository;

  LeaveRoom(this.repository);

  @override
  Future<Either<Failure, void>> call(LeaveRoomParams params) async {
    return await repository.leaveRoom(params.roomId, params.userId);
  }
}

class ToggleAudio implements UseCase<void, NoParams> {
  final WebRTCRepository repository;

  ToggleAudio(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.toggleAudio();
  }
}

class ToggleVideo implements UseCase<void, NoParams> {
  final WebRTCRepository repository;

  ToggleVideo(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.toggleVideo();
  }
}

// Parameter classes
class JoinRoomParams extends Equatable {
  final String roomId;
  final String userId;

  const JoinRoomParams({required this.roomId, required this.userId});

  @override
  List<Object> get props => [roomId, userId];
}

class LeaveRoomParams extends Equatable {
  final String roomId;
  final String userId;

  const LeaveRoomParams({required this.roomId, required this.userId});

  @override
  List<Object> get props => [roomId, userId];
}

class SendSignalingMessage
    implements UseCase<void, SendSignalingMessageParams> {
  final WebRTCRepository repository;

  SendSignalingMessage(this.repository);

  @override
  Future<Either<Failure, void>> call(SendSignalingMessageParams params) async {
    return await repository.sendSignalingMessage(params.roomId, params.message);
  }
}

class ListenToSignalingMessages
    implements
        UseCase<Stream<SignalingMessage>, ListenToSignalingMessagesParams> {
  final WebRTCRepository repository;

  ListenToSignalingMessages(this.repository);

  @override
  Future<Either<Failure, Stream<SignalingMessage>>> call(
    ListenToSignalingMessagesParams params,
  ) async {
    return Right(
      repository.listenToSignalingMessages(params.roomId, params.userId),
    );
  }
}

class ListenToParticipants
    implements
        UseCase<Stream<List<RTCParticipant>>, ListenToParticipantsParams> {
  final WebRTCRepository repository;

  ListenToParticipants(this.repository);

  @override
  Future<Either<Failure, Stream<List<RTCParticipant>>>> call(
    ListenToParticipantsParams params,
  ) async {
    return Right(repository.listenToParticipants(params.roomId));
  }
}

class UpdateParticipantStatus
    implements UseCase<void, UpdateParticipantStatusParams> {
  final WebRTCRepository repository;

  UpdateParticipantStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(
    UpdateParticipantStatusParams params,
  ) async {
    return await repository.updateParticipantStatus(
      params.roomId,
      params.userId,
      params.isAudioOn,
      params.isVideoOn,
    );
  }
}

class DisposeWebRTC implements UseCase<void, NoParams> {
  final WebRTCRepository repository;

  DisposeWebRTC(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    await repository.dispose();
    return const Right(null);
  }
}

// Additional parameter classes
class SendSignalingMessageParams extends Equatable {
  final String roomId;
  final SignalingMessage message;

  const SendSignalingMessageParams({
    required this.roomId,
    required this.message,
  });

  @override
  List<Object> get props => [roomId, message];
}

class ListenToSignalingMessagesParams extends Equatable {
  final String roomId;
  final String userId;

  const ListenToSignalingMessagesParams({
    required this.roomId,
    required this.userId,
  });

  @override
  List<Object> get props => [roomId, userId];
}

class ListenToParticipantsParams extends Equatable {
  final String roomId;

  const ListenToParticipantsParams({required this.roomId});

  @override
  List<Object> get props => [roomId];
}

class UpdateParticipantStatusParams extends Equatable {
  final String roomId;
  final String userId;
  final bool isAudioOn;
  final bool isVideoOn;

  const UpdateParticipantStatusParams({
    required this.roomId,
    required this.userId,
    required this.isAudioOn,
    required this.isVideoOn,
  });

  @override
  List<Object> get props => [roomId, userId, isAudioOn, isVideoOn];
}
