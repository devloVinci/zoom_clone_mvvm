import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import '../network/network_info.dart';
import '../utils/shared_preferences_helper.dart';

// Data
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/auth_remote_data_source_impl.dart';
import '../../data/datasources/meeting_remote_data_source.dart';
import '../../data/datasources/meeting_remote_data_source_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/meeting_repository_impl.dart';

// Domain
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/meeting_repository.dart';
import '../../domain/usecases/auth/get_current_user.dart';
import '../../domain/usecases/auth/sign_in_with_email_and_password.dart';
import '../../domain/usecases/auth/sign_out.dart';
import '../../domain/usecases/auth/sign_up_with_email_and_password.dart';
import '../../domain/usecases/auth/watch_auth_state.dart';
import '../../domain/usecases/meeting/create_meeting.dart';
import '../../domain/usecases/meeting/get_user_meetings.dart';
import '../../domain/usecases/meeting/join_meeting.dart';

// Presentation
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/meeting/meeting_bloc.dart';

// WebRTC
import 'webrtc_injection.dart';

final getIt = GetIt.instance;

// Temporary manual DI setup until code generation works
Future<void> configureDependencies() async {
  // Register external dependencies
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);

  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    ),
  );

  // Core
  getIt.registerLazySingleton(() => SharedPreferencesHelper(getIt()));
  getIt.registerLazySingleton(() => NetworkInfo(getIt()));

  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<MeetingRemoteDataSource>(
    () => MeetingRemoteDataSourceImpl(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
  );
  getIt.registerLazySingleton<MeetingRepository>(
    () => MeetingRepositoryImpl(
      remoteDataSource: getIt(),
      authRemoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => SignInWithEmailAndPassword(getIt()));
  getIt.registerLazySingleton(() => SignUpWithEmailAndPassword(getIt()));
  getIt.registerLazySingleton(() => SignOut(getIt()));
  getIt.registerLazySingleton(() => GetCurrentUser(getIt()));
  getIt.registerLazySingleton(() => WatchAuthState(getIt()));

  getIt.registerLazySingleton(() => CreateMeeting(getIt()));
  getIt.registerLazySingleton(() => JoinMeeting(getIt()));
  getIt.registerLazySingleton(() => GetUserMeetings(getIt()));

  // Blocs
  getIt.registerFactory(
    () => AuthBloc(getIt(), getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerFactory(() => MeetingBloc(getIt(), getIt(), getIt()));

  // Setup WebRTC dependencies
  setupWebRTCDependencies();
}

@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firebaseFirestore => FirebaseFirestore.instance;

  @lazySingleton
  Dio get dio => Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );
}
