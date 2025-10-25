import '../models/meeting_model.dart';

abstract class MeetingRemoteDataSource {
  Future<MeetingModel> createMeeting({
    required String title,
    required String description,
    required String hostId,
    required String hostName,
    required DateTime scheduledAt,
    required int durationInMinutes,
    String? password,
    bool isRecordingEnabled = false,
  });

  Future<MeetingModel> getMeeting({required String meetingId});

  Future<List<MeetingModel>> getUserMeetings({required String userId});

  Future<MeetingModel> joinMeeting({
    required String meetingId,
    required String userId,
    String? password,
  });

  Future<void> leaveMeeting({
    required String meetingId,
    required String userId,
  });

  Future<MeetingModel> updateMeeting({
    required String meetingId,
    String? title,
    String? description,
    DateTime? scheduledAt,
    int? durationInMinutes,
    String? password,
    bool? isRecordingEnabled,
  });

  Future<void> deleteMeeting({required String meetingId});

  Future<void> endMeeting({required String meetingId});

  Stream<MeetingModel> watchMeeting({required String meetingId});
}
