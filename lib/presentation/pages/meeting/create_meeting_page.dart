import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../bloc/meeting/meeting_bloc.dart';
import 'webrtc_meeting_room_page.dart';

class CreateMeetingPage extends StatefulWidget {
  const CreateMeetingPage({super.key});

  @override
  State<CreateMeetingPage> createState() => _CreateMeetingPageState();
}

class _CreateMeetingPageState extends State<CreateMeetingPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _passwordController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final int _duration = 60; // minutes
  bool _isRecordingEnabled = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _onCreatePressed() {
    if (_formKey.currentState?.validate() ?? false) {
      final scheduledAt = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      context.read<MeetingBloc>().add(
        MeetingCreateRequested(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          scheduledAt: scheduledAt,
          durationInMinutes: _duration,
          password: _passwordController.text.isNotEmpty
              ? _passwordController.text
              : null,
          isRecordingEnabled: _isRecordingEnabled,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: BlocConsumer<MeetingBloc, MeetingState>(
        listener: (context, state) {
          if (state.status == MeetingStatus.success &&
              state.currentMeeting != null) {
            // Navigate to meeting room immediately after creation
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
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Instant Meeting',
                    style: AppTheme.montserratStyle(24, Colors.black),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _titleController,
                    style: AppTheme.montserratStyle(16, Colors.black),
                    decoration: const InputDecoration(
                      labelText: 'Meeting Title',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a meeting title';
                      }
                      return null;
                    },
                    enabled: state.status != MeetingStatus.loading,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    style: AppTheme.montserratStyle(16, Colors.black),
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    enabled: state.status != MeetingStatus.loading,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    style: AppTheme.montserratStyle(16, Colors.black),
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password (Optional)',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                      helperText: 'Leave empty for public meeting',
                    ),
                    enabled: state.status != MeetingStatus.loading,
                  ),
                  const SizedBox(height: 20),
                  CheckboxListTile(
                    title: Text(
                      'Enable Recording',
                      style: AppTheme.ralewayStyle(16, Colors.black),
                    ),
                    subtitle: Text(
                      'Record this meeting for later viewing',
                      style: AppTheme.ralewayStyle(
                        12,
                        Colors.grey[600],
                        FontWeight.w400,
                      ),
                    ),
                    value: _isRecordingEnabled,
                    onChanged: state.status != MeetingStatus.loading
                        ? (value) {
                            setState(() {
                              _isRecordingEnabled = value ?? false;
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: 30),
                  if (state.status == MeetingStatus.loading)
                    const Center(child: CircularProgressIndicator())
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _onCreatePressed,
                        icon: const Icon(Icons.videocam),
                        label: Text(
                          'Start Meeting Now',
                          style: AppTheme.ralewayStyle(16, Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
