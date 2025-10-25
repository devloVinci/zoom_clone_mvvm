import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../bloc/meeting/meeting_bloc.dart';
import 'create_meeting_page.dart';
import 'join_meeting_page.dart';
import 'webrtc_meeting_room_page.dart';

class MeetingPage extends StatefulWidget {
  const MeetingPage({super.key});

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTabHeader(String title) {
    return SizedBox(
      width: 150,
      height: 50,
      child: Card(
        child: Center(
          child: Text(title, style: AppTheme.ralewayStyle(15, Colors.black)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MyZoom Clone',
          style: AppTheme.ralewayStyle(20, Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            _buildTabHeader('Join Meeting'),
            _buildTabHeader('Create Meeting'),
          ],
        ),
      ),
      body: BlocListener<MeetingBloc, MeetingState>(
        listener: (context, state) {
          if (state.status == MeetingStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.status == MeetingStatus.success &&
              state.currentMeeting != null) {
            // Navigate to WebRTC meeting room after successful join
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebRTCMeetingRoomPage(
                  meeting: state.currentMeeting!,
                  userId: FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
                ),
              ),
            );
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: const [JoinMeetingPage(), CreateMeetingPage()],
        ),
      ),
    );
  }
}
