import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validation_utils.dart';
import '../../bloc/meeting/meeting_bloc.dart';

class JoinMeetingPage extends StatefulWidget {
  const JoinMeetingPage({super.key});

  @override
  State<JoinMeetingPage> createState() => _JoinMeetingPageState();
}

class _JoinMeetingPageState extends State<JoinMeetingPage> {
  final _formKey = GlobalKey<FormState>();
  final _meetingIdController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _meetingIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onJoinPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<MeetingBloc>().add(
        MeetingJoinRequested(
          meetingId: _meetingIdController.text.trim(),
          password: _passwordController.text.isNotEmpty
              ? _passwordController.text
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: BlocBuilder<MeetingBloc, MeetingState>(
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Join a Meeting',
                  style: AppTheme.montserratStyle(24, Colors.black),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _meetingIdController,
                  style: AppTheme.montserratStyle(16, Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Meeting ID',
                    prefixIcon: const Icon(Icons.meeting_room),
                    border: const OutlineInputBorder(),
                    hintStyle: AppTheme.ralewayStyle(
                      14,
                      Colors.grey,
                      FontWeight.w400,
                    ),
                  ),
                  validator: ValidationUtils.validateMeetingId,
                  enabled: state.status != MeetingStatus.loading,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  style: AppTheme.montserratStyle(16, Colors.black),
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password (Optional)',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    hintStyle: AppTheme.ralewayStyle(
                      14,
                      Colors.grey,
                      FontWeight.w400,
                    ),
                  ),
                  enabled: state.status != MeetingStatus.loading,
                ),
                const SizedBox(height: 40),
                if (state.status == MeetingStatus.loading)
                  const CircularProgressIndicator()
                else
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onJoinPressed,
                      child: Text(
                        'Join Meeting',
                        style: AppTheme.ralewayStyle(16, Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
