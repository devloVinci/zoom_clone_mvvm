import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../../data/datasources/webrtc_remote_data_source.dart';
import '../../data/repositories/webrtc_repository_impl.dart';
import '../../domain/repositories/webrtc_repository.dart';
import '../../domain/usecases/webrtc/webrtc_usecases.dart';
import '../../presentation/bloc/webrtc/webrtc_bloc.dart';

final sl = GetIt.instance;

void setupWebRTCDependencies() {
  // External
  if (!sl.isRegistered<FirebaseFirestore>()) {
    sl.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
  }

  // Data sources
  sl.registerLazySingleton<WebRTCRemoteDataSource>(
    () => WebRTCRemoteDataSourceImpl(firestore: sl()),
  );

  // Repository
  sl.registerLazySingleton<WebRTCRepository>(
    () => WebRTCRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => InitializeWebRTC(sl()));
  sl.registerLazySingleton(() => JoinRoom(sl()));
  sl.registerLazySingleton(() => LeaveRoom(sl()));
  sl.registerLazySingleton(() => SendSignalingMessage(sl()));
  sl.registerLazySingleton(() => ListenToSignalingMessages(sl()));
  sl.registerLazySingleton(() => ListenToParticipants(sl()));
  sl.registerLazySingleton(() => UpdateParticipantStatus(sl()));
  sl.registerLazySingleton(() => ToggleAudio(sl()));
  sl.registerLazySingleton(() => ToggleVideo(sl()));
  sl.registerLazySingleton(() => DisposeWebRTC(sl()));

  // BLoC
  sl.registerFactory(
    () => WebRTCBloc(
      initializeWebRTC: sl(),
      joinRoom: sl(),
      leaveRoom: sl(),
      sendSignalingMessage: sl(),
      listenToSignalingMessages: sl(),
      listenToParticipants: sl(),
      updateParticipantStatus: sl(),
      toggleAudio: sl(),
      toggleVideo: sl(),
      disposeWebRTC: sl(),
    ),
  );
}
