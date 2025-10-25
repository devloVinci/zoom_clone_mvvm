import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/audio_service.dart';
import '../../../core/services/participant_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/meeting.dart';

class MeetingRoomPage extends StatefulWidget {
  final Meeting meeting;

  const MeetingRoomPage({super.key, required this.meeting});

  @override
  State<MeetingRoomPage> createState() => _MeetingRoomPageState();
}

class _MeetingRoomPageState extends State<MeetingRoomPage> {
  bool _isMuted = true;
  bool _isVideoOff = false;
  bool _isShareIdVisible = false;
  bool _showParticipants = false;

  final AudioService _audioService = AudioService();
  final ParticipantService _participantService = ParticipantService();

  void _copyMeetingId() {
    Clipboard.setData(ClipboardData(text: widget.meeting.id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meeting ID copied to clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareMeetingId() {
    setState(() {
      _isShareIdVisible = !_isShareIdVisible;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize meeting with participants
    _participantService.initializeMeeting(
      widget.meeting.hostName,
      '${widget.meeting.hostName.toLowerCase().replaceAll(' ', '.')}@example.com',
    );
  }

  Future<void> _toggleMute() async {
    await _audioService.toggleMute();
    setState(() {
      _isMuted = _audioService.isMuted;
    });
  }

  void _toggleParticipants() {
    setState(() {
      _showParticipants = !_showParticipants;
    });
  }

  String _formatJoinTime(DateTime joinTime) {
    final now = DateTime.now();
    final difference = now.difference(joinTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    _participantService.clearMeeting();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(
            widget.meeting.title,
            style: AppTheme.ralewayStyle(18, Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: _shareMeetingId,
              icon: const Icon(Icons.share),
              tooltip: 'Share Meeting ID',
            ),
          ],
        ),
        body: Column(
          children: [
            // Share ID Panel
            if (_isShareIdVisible)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.grey[900],
                child: Column(
                  children: [
                    Text(
                      'Share Meeting ID',
                      style: AppTheme.montserratStyle(16, Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.meeting.id,
                              style: AppTheme.ralewayStyle(18, Colors.white),
                            ),
                          ),
                          IconButton(
                            onPressed: _copyMeetingId,
                            icon: const Icon(Icons.copy, color: Colors.white),
                            tooltip: 'Copy ID',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.meeting.password != null)
                      Text(
                        'Password: ${widget.meeting.password}',
                        style: AppTheme.ralewayStyle(14, Colors.grey[300]),
                      ),
                  ],
                ),
              ),

            // Participants Panel
            if (_showParticipants)
              Container(
                width: double.infinity,
                height: 200,
                padding: const EdgeInsets.all(16),
                color: Colors.grey[850],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Participants (${_participantService.participantCount})',
                          style: AppTheme.montserratStyle(16, Colors.white),
                        ),
                        IconButton(
                          onPressed: () {
                            _participantService.simulateParticipantJoin();
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.person_add,
                            color: Colors.white,
                          ),
                          tooltip: 'Add Participant',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _participantService.participants.length,
                        itemBuilder: (context, index) {
                          final participant =
                              _participantService.participants[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: participant.isHost
                                      ? Colors.orange
                                      : Colors.blue,
                                  child: Text(
                                    participant.name
                                        .split(' ')
                                        .map((n) => n[0])
                                        .join(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            participant.name,
                                            style: AppTheme.ralewayStyle(
                                              14,
                                              Colors.white,
                                            ),
                                          ),
                                          if (participant.isHost)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                left: 8,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.orange,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Text(
                                                'HOST',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      Text(
                                        'Joined ${_formatJoinTime(participant.joinedAt)}',
                                        style: AppTheme.ralewayStyle(
                                          10,
                                          Colors.grey[400],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      participant.isMuted
                                          ? Icons.mic_off
                                          : Icons.mic,
                                      color: participant.isMuted
                                          ? Colors.red
                                          : Colors.green,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      participant.isVideoOn
                                          ? Icons.videocam
                                          : Icons.videocam_off,
                                      color: participant.isVideoOn
                                          ? Colors.green
                                          : Colors.red,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Video Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.grey[900]!, Colors.black],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Video placeholder
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isVideoOff ? Icons.videocam_off : Icons.person,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.meeting.hostName,
                      style: AppTheme.montserratStyle(20, Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Meeting in progress...',
                      style: AppTheme.ralewayStyle(
                        14,
                        Colors.grey[300],
                        FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Recording indicator
                    if (_audioService.isRecording)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.fiber_manual_record,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Recording Audio',
                              style: AppTheme.ralewayStyle(
                                12,
                                Colors.white,
                                FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Control Panel
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey[900],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute/Unmute
                  GestureDetector(
                    onTap: _toggleMute,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _isMuted ? Colors.red : Colors.grey[700],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isMuted ? Icons.mic_off : Icons.mic,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                  // Video On/Off
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isVideoOff = !_isVideoOff;
                      });
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _isVideoOff ? Colors.red : Colors.grey[700],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isVideoOff ? Icons.videocam_off : Icons.videocam,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                  // End Call
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('End Meeting'),
                          content: const Text(
                            'Are you sure you want to end this meeting?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                Navigator.pop(context); // Close meeting room
                              },
                              child: const Text('End Meeting'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                  // Participants
                  GestureDetector(
                    onTap: _toggleParticipants,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.people,
                            color: Colors.white,
                            size: 30,
                          ),
                          if (_participantService.participantCount > 1)
                            Positioned(
                              top: 5,
                              right: 5,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${_participantService.participantCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
