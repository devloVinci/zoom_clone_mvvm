class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _isRecording = false;
  bool _isMuted = false;
  DateTime? _recordingStartTime;

  bool get isRecording => _isRecording;
  bool get isMuted => _isMuted;

  /// Request microphone permission (simulated)
  Future<bool> requestMicrophonePermission() async {
    // Simulate permission granted for demo purposes
    print('🔒 Microphone permission granted (simulated)');
    return true;
  }

  /// Start recording audio (simulated)
  Future<bool> startRecording() async {
    try {
      // Check permission
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) {
        return false;
      }

      // Simulate recording start
      _isRecording = true;
      _recordingStartTime = DateTime.now();
      print('🎙️ Audio recording started at $_recordingStartTime');
      return true;
    } catch (e) {
      print('Error starting recording: $e');
      return false;
    }
  }

  /// Stop recording audio (simulated)
  Future<String?> stopRecording() async {
    try {
      if (_isRecording) {
        _isRecording = false;
        final duration = DateTime.now().difference(_recordingStartTime!);
        print('🎙️ Audio recording stopped. Duration: ${duration.inSeconds}s');
        return 'simulated_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      }
      return null;
    } catch (e) {
      print('Error stopping recording: $e');
      return null;
    }
  }

  /// Play recorded audio (simulated)
  Future<void> playRecording() async {
    try {
      print('▶️ Playing simulated audio recording...');
      // Simulate playback delay
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('Error playing recording: $e');
    }
  }

  /// Stop audio playback (simulated)
  Future<void> stopPlayback() async {
    try {
      print('⏹️ Stopping audio playback...');
    } catch (e) {
      print('Error stopping playback: $e');
    }
  }

  /// Toggle mute/unmute
  void toggleMute() {
    _isMuted = !_isMuted;
    print('🔇 Audio ${_isMuted ? 'muted' : 'unmuted'}');
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
