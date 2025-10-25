import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/meeting/meeting_bloc.dart';
import '../meeting/meeting_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    BlocProvider(
      create: (context) => getIt<MeetingBloc>(),
      child: const MeetingPage(),
    ),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryColor,
        selectedLabelStyle: AppTheme.montserratStyle(14, AppTheme.primaryColor),
        unselectedItemColor: Colors.black,
        unselectedLabelStyle: AppTheme.montserratStyle(14, Colors.black),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_call, size: 32),
            label: 'Meetings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 32),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
