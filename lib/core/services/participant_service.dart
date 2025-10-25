import 'dart:math';

class Participant {
  final String id;
  final String name;
  final String email;
  final bool isMuted;
  final bool isVideoOn;
  final bool isHost;
  final DateTime joinedAt;

  const Participant({
    required this.id,
    required this.name,
    required this.email,
    required this.isMuted,
    required this.isVideoOn,
    required this.isHost,
    required this.joinedAt,
  });

  Participant copyWith({bool? isMuted, bool? isVideoOn}) {
    return Participant(
      id: id,
      name: name,
      email: email,
      isMuted: isMuted ?? this.isMuted,
      isVideoOn: isVideoOn ?? this.isVideoOn,
      isHost: isHost,
      joinedAt: joinedAt,
    );
  }
}

class ParticipantService {
  static final ParticipantService _instance = ParticipantService._internal();
  factory ParticipantService() => _instance;
  ParticipantService._internal();

  final List<Participant> _participants = [];
  final Random _random = Random();

  List<Participant> get participants => List.unmodifiable(_participants);

  /// Initialize meeting with host and some demo participants
  void initializeMeeting(String hostName, String hostEmail) {
    _participants.clear();

    // Add host
    _participants.add(
      Participant(
        id: 'host_${DateTime.now().millisecondsSinceEpoch}',
        name: hostName,
        email: hostEmail,
        isMuted: false,
        isVideoOn: true,
        isHost: true,
        joinedAt: DateTime.now(),
      ),
    );

    // Add some demo participants
    _addDemoParticipants();

    print('🎯 Meeting initialized with ${_participants.length} participants');
  }

  void _addDemoParticipants() {
    final demoUsers = [
      {'name': 'Alice Johnson', 'email': 'alice@example.com'},
      {'name': 'Bob Smith', 'email': 'bob@example.com'},
      {'name': 'Carol Davis', 'email': 'carol@example.com'},
      {'name': 'David Wilson', 'email': 'david@example.com'},
    ];

    // Simulate 2-4 participants joining
    final participantCount = 2 + _random.nextInt(3);

    for (int i = 0; i < participantCount && i < demoUsers.length; i++) {
      final user = demoUsers[i];
      _participants.add(
        Participant(
          id: 'participant_${DateTime.now().millisecondsSinceEpoch}_$i',
          name: user['name']!,
          email: user['email']!,
          isMuted: _random.nextBool(),
          isVideoOn: _random.nextBool(),
          isHost: false,
          joinedAt: DateTime.now().subtract(
            Duration(minutes: _random.nextInt(30)),
          ),
        ),
      );

      // Simulate joining delay
      Future.delayed(Duration(seconds: i + 1), () {
        print('👤 ${user['name']} joined the meeting');
      });
    }
  }

  /// Toggle participant mute status
  void toggleParticipantMute(String participantId) {
    final index = _participants.indexWhere((p) => p.id == participantId);
    if (index != -1) {
      _participants[index] = _participants[index].copyWith(
        isMuted: !_participants[index].isMuted,
      );
      print(
        '🔇 ${_participants[index].name} ${_participants[index].isMuted ? 'muted' : 'unmuted'}',
      );
    }
  }

  /// Toggle participant video status
  void toggleParticipantVideo(String participantId) {
    final index = _participants.indexWhere((p) => p.id == participantId);
    if (index != -1) {
      _participants[index] = _participants[index].copyWith(
        isVideoOn: !_participants[index].isVideoOn,
      );
      print(
        '📹 ${_participants[index].name} turned video ${_participants[index].isVideoOn ? 'on' : 'off'}',
      );
    }
  }

  /// Simulate participant joining
  void simulateParticipantJoin() {
    final names = [
      'Emma Brown',
      'James Miller',
      'Sophia Garcia',
      'Liam Martinez',
    ];
    final randomName = names[_random.nextInt(names.length)];
    final email =
        '${randomName.toLowerCase().replaceAll(' ', '.')}@example.com';

    _participants.add(
      Participant(
        id: 'participant_${DateTime.now().millisecondsSinceEpoch}',
        name: randomName,
        email: email,
        isMuted: true, // Join muted by default
        isVideoOn: _random.nextBool(),
        isHost: false,
        joinedAt: DateTime.now(),
      ),
    );

    print('✅ $randomName joined the meeting');
  }

  /// Remove participant
  void removeParticipant(String participantId) {
    final participant = _participants.firstWhere((p) => p.id == participantId);
    _participants.removeWhere((p) => p.id == participantId);
    print('👋 ${participant.name} left the meeting');
  }

  /// Get participant count
  int get participantCount => _participants.length;

  /// Get host participant
  Participant? get host => _participants.firstWhere((p) => p.isHost);

  /// Clear all participants
  void clearMeeting() {
    _participants.clear();
    print('🧹 Meeting cleared');
  }
}
