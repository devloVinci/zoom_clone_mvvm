class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _isRecording = false;
  bool _isMuted = true;
  DateTime? _recordingStartTime;
  final List<String> _recordedSessions = [];

  bool get isRecording => _isRecording;
  bool get isMuted => _isMuted;
  List<String> get recordedSessions => _recordedSessions;

  /// Request microphone permission (simulated)
  Future<bool> requestMicrophonePermission() async {
    // Simulate permission request
    print('🔒 Requesting microphone permission...');
    await Future.delayed(const Duration(milliseconds: 500));
    print('✅ Microphone permission granted');
    return true;
  }

  /// Start recording audio
  Future<bool> startRecording() async {
    try {
      // Check permission
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) {
        return false;
      }

      // Start recording
      _isRecording = true;
      _isMuted = false;
      _recordingStartTime = DateTime.now();
      print('🎙️ Audio recording started at $_recordingStartTime');
      return true;
    } catch (e) {
      print('Error starting recording: $e');
      return false;
    }
  }

  /// Stop recording audio
  Future<String?> stopRecording() async {
    try {
      if (_isRecording) {
        _isRecording = false;
        _isMuted = true;
        final duration = DateTime.now().difference(_recordingStartTime!);
        final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
        _recordedSessions.add(
          'Recording ${_recordedSessions.length + 1} (${duration.inSeconds}s)',
        );
        print('🎙️ Audio recording stopped. Duration: ${duration.inSeconds}s');
        return sessionId;
      }
      return null;
    } catch (e) {
      print('Error stopping recording: $e');
      return null;
    }
  }

  /// Toggle mute/unmute
  Future<void> toggleMute() async {
    if (_isMuted) {
      await startRecording();
    } else {
      await stopRecording();
    }
  }

  /// Get recording duration
  Duration? getRecordingDuration() {
    if (_recordingStartTime != null && _isRecording) {
      return DateTime.now().difference(_recordingStartTime!);
    }
    return null;
  }

  /// Dispose resources
  Future<void> dispose() async {
    if (_isRecording) {
      await stopRecording();
    }
    print('🔧 Audio service disposed');
  }
}
