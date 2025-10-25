import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../core/di/webrtc_injection.dart';
import '../../../domain/entities/meeting.dart';
import '../../../domain/entities/rtc_entities.dart';
import '../../bloc/webrtc/webrtc_bloc.dart';
import '../../bloc/webrtc/webrtc_event.dart';
import '../../bloc/webrtc/webrtc_state.dart';

class WebRTCMeetingRoomPage extends StatefulWidget {
  final Meeting meeting;
  final String userId;

  const WebRTCMeetingRoomPage({
    super.key,
    required this.meeting,
    required this.userId,
  });

  @override
  State<WebRTCMeetingRoomPage> createState() => _WebRTCMeetingRoomPageState();
}

class _WebRTCMeetingRoomPageState extends State<WebRTCMeetingRoomPage> {
  late WebRTCBloc _webRTCBloc;
  bool _showParticipants = false;

  @override
  void initState() {
    super.initState();
    _webRTCBloc = sl<WebRTCBloc>();

    // Initialize WebRTC when the page loads
    _webRTCBloc.add(const InitializeWebRTCEvent());
  }

  @override
  void dispose() {
    _webRTCBloc.add(const DisposeWebRTCEvent());
    _webRTCBloc.close();
    super.dispose();
  }

  void _joinMeeting() {
    _webRTCBloc.add(
      JoinRoomEvent(roomId: widget.meeting.id, userId: widget.userId),
    );
  }

  void _leaveMeeting() {
    _webRTCBloc.add(
      LeaveRoomEvent(roomId: widget.meeting.id, userId: widget.userId),
    );
    Navigator.of(context).pop();
  }

  void _toggleAudio() {
    _webRTCBloc.add(const ToggleAudioEvent());
  }

  void _toggleParticipants() {
    setState(() {
      _showParticipants = !_showParticipants;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(widget.meeting.title),
          actions: [
            IconButton(
              tooltip: 'Copy meeting ID',
              icon: const Icon(Icons.copy),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: widget.meeting.id));
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Meeting ID copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.people),
              onPressed: _toggleParticipants,
            ),
            IconButton(
              icon: const Icon(Icons.call_end),
              onPressed: _leaveMeeting,
              color: Colors.red,
            ),
          ],
        ),
        body: BlocProvider(
          create: (context) => _webRTCBloc,
          child: BlocConsumer<WebRTCBloc, WebRTCState>(
            listener: (context, state) {
              if (state is WebRTCError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('WebRTC Error: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is WebRTCInitialized) {
                // Auto-join the meeting once WebRTC is initialized
                _joinMeeting();
              }
            },
            builder: (context, state) {
              return Stack(
                children: [
                  // Main video area
                  _buildMainVideoArea(state),

                  // Participants panel (if visible)
                  if (_showParticipants) _buildParticipantsPanel(state),

                  // Control buttons at the bottom
                  _buildControlButtons(state),

                  // Connection status
                  _buildConnectionStatus(state),

                  // Debug overlay (helps diagnose release issues)
                  _buildDebugOverlay(state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDebugOverlay(WebRTCState state) {
    String label;
    if (state is WebRTCInitial) {
      label = 'state=Initial';
    } else if (state is WebRTCLoading) {
      label = 'state=Loading';
    } else if (state is WebRTCInitialized) {
      label = 'state=Initialized';
    } else if (state is WebRTCRoomJoined) {
      label =
          'state=RoomJoined participants=${state.participants.length} audioOn=${state.isAudioEnabled}';
    } else if (state is WebRTCError) {
      label = 'state=Error msg=${state.message}';
    } else {
      label = 'state=Unknown';
    }

    return Positioned(
      bottom: 110,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildMainVideoArea(WebRTCState state) {
    return Positioned.fill(
      child: Container(
        width: double.infinity,
        color: Colors.black, // use black background for voice-only room
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Local audio indicator
            if (state is WebRTCRoomJoined && state.localStream != null)
              Container(
                width: 150,
                height: 50,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.mic, color: Colors.white, size: 40),
                ),
              )
            else
              Container(
                width: 150,
                height: 50,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.mic_off, color: Colors.white, size: 40),
                ),
              ),

            // Participants audio indicators
            if (state is WebRTCRoomJoined)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.participants.length,
                  itemBuilder: (context, index) {
                    final participant = state.participants[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Text(
                          participant.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        participant.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Icon(
                        participant.isAudioOn ? Icons.mic : Icons.mic_off,
                        color: participant.isAudioOn
                            ? Colors.green
                            : Colors.red,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsPanel(WebRTCState state) {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 100,
      width: 300,
      child: Container(
        color: Colors.black87,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Participants',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: state is WebRTCRoomJoined
                  ? ListView.builder(
                      itemCount: state.participants.length,
                      itemBuilder: (context, index) {
                        final participant = state.participants[index];
                        return _buildParticipantTile(participant);
                      },
                    )
                  : const Center(
                      child: Text(
                        'No participants',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantTile(RTCParticipant participant) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(
          participant.name.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        participant.name,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        participant.email,
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            participant.isAudioOn ? Icons.mic : Icons.mic_off,
            color: participant.isAudioOn ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 4),
          Icon(
            participant.isVideoOn ? Icons.videocam : Icons.videocam_off,
            color: participant.isVideoOn ? Colors.green : Colors.red,
            size: 16,
          ),
          if (participant.isHost) ...[
            const SizedBox(width: 4),
            const Icon(Icons.star, color: Colors.amber, size: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildControlButtons(WebRTCState state) {
    final isInRoom = state is WebRTCRoomJoined;
    bool isAudioEnabled = false;

    if (isInRoom) {
      final roomState = state;
      isAudioEnabled = roomState.isAudioEnabled;
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 100,
        color: Colors.black87,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Audio toggle
            FloatingActionButton(
              heroTag: "audio",
              onPressed: isInRoom ? _toggleAudio : null,
              backgroundColor: isInRoom && isAudioEnabled
                  ? Colors.white
                  : Colors.red,
              child: Icon(
                isInRoom && isAudioEnabled ? Icons.mic : Icons.mic_off,
                color: isInRoom && isAudioEnabled ? Colors.black : Colors.white,
              ),
            ),

            // Leave call
            FloatingActionButton(
              heroTag: "leave",
              onPressed: _leaveMeeting,
              backgroundColor: Colors.red,
              child: const Icon(Icons.call_end, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(WebRTCState state) {
    String statusText;
    Color statusColor;

    switch (state.runtimeType) {
      case WebRTCInitial:
        statusText = 'Initializing...';
        statusColor = Colors.orange;
        break;
      case WebRTCLoading:
        statusText = 'Connecting...';
        statusColor = Colors.orange;
        break;
      case WebRTCInitialized:
        statusText = 'Ready to join';
        statusColor = Colors.blue;
        break;
      case WebRTCRoomJoined:
        final roomState = state as WebRTCRoomJoined;
        statusText =
            'Connected (${roomState.participants.length} participants)';
        statusColor = Colors.green;
        break;
      case WebRTCError:
        statusText = 'Connection Error';
        statusColor = Colors.red;
        break;
      default:
        statusText = 'Unknown';
        statusColor = Colors.grey;
    }

    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          statusText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
