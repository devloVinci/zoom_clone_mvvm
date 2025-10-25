import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/webrtc/webrtc_usecases.dart';
import '../../../core/usecases/usecase.dart';
import 'webrtc_event.dart';
import 'webrtc_state.dart';

class WebRTCBloc extends Bloc<WebRTCEvent, WebRTCState> {
  final InitializeWebRTC initializeWebRTC;
  final JoinRoom joinRoom;
  final LeaveRoom leaveRoom;
  final SendSignalingMessage sendSignalingMessage;
  final ListenToSignalingMessages listenToSignalingMessages;
  final ListenToParticipants listenToParticipants;
  final UpdateParticipantStatus updateParticipantStatus;
  final ToggleAudio toggleAudio;
  final ToggleVideo toggleVideo;
  final DisposeWebRTC disposeWebRTC;

  StreamSubscription? _signalingSubscription;
  StreamSubscription? _participantsSubscription;

  WebRTCBloc({
    required this.initializeWebRTC,
    required this.joinRoom,
    required this.leaveRoom,
    required this.sendSignalingMessage,
    required this.listenToSignalingMessages,
    required this.listenToParticipants,
    required this.updateParticipantStatus,
    required this.toggleAudio,
    required this.toggleVideo,
    required this.disposeWebRTC,
  }) : super(const WebRTCInitial()) {
    on<InitializeWebRTCEvent>(_onInitializeWebRTC);
    on<JoinRoomEvent>(_onJoinRoom);
    on<LeaveRoomEvent>(_onLeaveRoom);
    on<SendSignalingMessageEvent>(_onSendSignalingMessage);
    on<ToggleAudioEvent>(_onToggleAudio);
    on<ToggleVideoEvent>(_onToggleVideo);
    on<ParticipantsUpdatedEvent>(_onParticipantsUpdated);
    on<SignalingMessageReceivedEvent>(_onSignalingMessageReceived);
    on<UpdateParticipantStatusEvent>(_onUpdateParticipantStatus);
    on<DisposeWebRTCEvent>(_onDisposeWebRTC);
  }

  Future<void> _onInitializeWebRTC(
    InitializeWebRTCEvent event,
    Emitter<WebRTCState> emit,
  ) async {
    emit(const WebRTCLoading());

    final result = await initializeWebRTC(NoParams());

    result.fold(
      (failure) => emit(WebRTCError(failure.message)),
      (localStream) => emit(WebRTCInitialized(localStream: localStream)),
    );
  }

  Future<void> _onJoinRoom(
    JoinRoomEvent event,
    Emitter<WebRTCState> emit,
  ) async {
    emit(const WebRTCLoading());

    final params = JoinRoomParams(roomId: event.roomId, userId: event.userId);

    final result = await joinRoom(params);

    await result.fold((failure) async => emit(WebRTCError(failure.message)), (
      _,
    ) async {
      // Start listening to participants and signaling messages
      _startListeningToParticipants(event.roomId);
      _startListeningToSignalingMessages(event.roomId, event.userId);

      emit(WebRTCRoomJoined(roomId: event.roomId, userId: event.userId));
    });
  }

  Future<void> _onLeaveRoom(
    LeaveRoomEvent event,
    Emitter<WebRTCState> emit,
  ) async {
    final params = LeaveRoomParams(roomId: event.roomId, userId: event.userId);

    await leaveRoom(params);

    // Stop listening to streams
    await _signalingSubscription?.cancel();
    await _participantsSubscription?.cancel();

    emit(const WebRTCInitial());
  }

  Future<void> _onSendSignalingMessage(
    SendSignalingMessageEvent event,
    Emitter<WebRTCState> emit,
  ) async {
    final params = SendSignalingMessageParams(
      roomId: event.roomId,
      message: event.message,
    );

    await sendSignalingMessage(params);
  }

  Future<void> _onToggleAudio(
    ToggleAudioEvent event,
    Emitter<WebRTCState> emit,
  ) async {
    final result = await toggleAudio(NoParams());

    result.fold((failure) => emit(WebRTCError(failure.message)), (_) {
      if (state is WebRTCRoomJoined) {
        final currentState = state as WebRTCRoomJoined;
        emit(
          currentState.copyWith(isAudioEnabled: !currentState.isAudioEnabled),
        );
      }
    });
  }

  Future<void> _onToggleVideo(
    ToggleVideoEvent event,
    Emitter<WebRTCState> emit,
  ) async {
    final result = await toggleVideo(NoParams());

    result.fold((failure) => emit(WebRTCError(failure.message)), (_) {
      if (state is WebRTCRoomJoined) {
        final currentState = state as WebRTCRoomJoined;
        emit(
          currentState.copyWith(isVideoEnabled: !currentState.isVideoEnabled),
        );
      }
    });
  }

  void _onParticipantsUpdated(
    ParticipantsUpdatedEvent event,
    Emitter<WebRTCState> emit,
  ) {
    if (state is WebRTCRoomJoined) {
      final currentState = state as WebRTCRoomJoined;
      emit(currentState.copyWith(participants: event.participants));
    }
  }

  void _onSignalingMessageReceived(
    SignalingMessageReceivedEvent event,
    Emitter<WebRTCState> emit,
  ) {
    // Handle signaling message (offer, answer, ICE candidate)
    // This would typically trigger peer connection operations
    // For now, we'll just log it (implementation would depend on WebRTC signaling logic)
  }

  Future<void> _onUpdateParticipantStatus(
    UpdateParticipantStatusEvent event,
    Emitter<WebRTCState> emit,
  ) async {
    final params = UpdateParticipantStatusParams(
      roomId: event.roomId,
      userId: event.userId,
      isAudioOn: event.isAudioOn,
      isVideoOn: event.isVideoOn,
    );

    await updateParticipantStatus(params);
  }

  Future<void> _onDisposeWebRTC(
    DisposeWebRTCEvent event,
    Emitter<WebRTCState> emit,
  ) async {
    await _signalingSubscription?.cancel();
    await _participantsSubscription?.cancel();

    await disposeWebRTC(NoParams());
    emit(const WebRTCDisposed());
  }

  void _startListeningToParticipants(String roomId) async {
    final params = ListenToParticipantsParams(roomId: roomId);
    final result = await listenToParticipants(params);
    result.fold((failure) => add(ParticipantsUpdatedEvent([])), (stream) {
      _participantsSubscription = stream.listen(
        (participants) => add(ParticipantsUpdatedEvent(participants)),
      );
    });
  }

  void _startListeningToSignalingMessages(String roomId, String userId) async {
    final params = ListenToSignalingMessagesParams(
      roomId: roomId,
      userId: userId,
    );
    final result = await listenToSignalingMessages(params);
    result.fold(
      (failure) {}, // Handle error silently for now
      (stream) {
        _signalingSubscription = stream.listen(
          (message) => add(SignalingMessageReceivedEvent(message)),
        );
      },
    );
  }

  @override
  Future<void> close() async {
    await _signalingSubscription?.cancel();
    await _participantsSubscription?.cancel();
    return super.close();
  }
}
