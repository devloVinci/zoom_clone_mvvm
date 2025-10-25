import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/pages/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize dependency injection
  await configureDependencies();

  runApp(const MyZoomCloneApp());
}

class MyZoomCloneApp extends StatelessWidget {
  const MyZoomCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<AuthBloc>()..add(const AuthStarted()),
        ),
      ],
      child: MaterialApp(
        title: 'MyZoom Clone',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppView(),
      ),
    );
  }
}
