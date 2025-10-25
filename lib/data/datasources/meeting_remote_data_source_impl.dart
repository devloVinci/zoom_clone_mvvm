import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/meeting.dart';
import '../models/meeting_model.dart';
import 'meeting_remote_data_source.dart';

@LazySingleton(as: MeetingRemoteDataSource)
class MeetingRemoteDataSourceImpl implements MeetingRemoteDataSource {
  final FirebaseFirestore _firebaseFirestore;

  MeetingRemoteDataSourceImpl(this._firebaseFirestore);

  @override
  Future<MeetingModel> createMeeting({
    required String title,
    required String description,
    required String hostId,
    required String hostName,
    required DateTime scheduledAt,
    required int durationInMinutes,
    String? password,
    bool isRecordingEnabled = false,
  }) async {
    try {
      final now = DateTime.now();
      final meetingRef = _firebaseFirestore
          .collection(AppConstants.meetingsCollection)
          .doc();

      final meetingData = {
        'title': title,
        'description': description,
        'hostId': hostId,
        'hostName': hostName,
        'scheduledAt': scheduledAt.toIso8601String(),
        'durationInMinutes': durationInMinutes,
        'status': MeetingStatus.scheduled.name,
        'participantIds': <String>[],
        'password': password,
        'isRecordingEnabled': isRecordingEnabled,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      await meetingRef.set(meetingData);

      return MeetingModel.fromJson({'id': meetingRef.id, ...meetingData});
    } catch (e) {
      throw MeetingException(e.toString());
    }
  }

  @override
  Future<MeetingModel> getMeeting({required String meetingId}) async {
    try {
      final meetingDoc = await _firebaseFirestore
          .collection(AppConstants.meetingsCollection)
          .doc(meetingId)
          .get();

      if (!meetingDoc.exists) {
        throw const MeetingException('Meeting not found');
      }

      return MeetingModel.fromJson({
        'id': meetingDoc.id,
        ...meetingDoc.data()!,
      });
    } catch (e) {
      if (e is MeetingException) rethrow;
      throw MeetingException(e.toString());
    }
  }

  @override
  Future<List<MeetingModel>> getUserMeetings({required String userId}) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection(AppConstants.meetingsCollection)
          .where('hostId', isEqualTo: userId)
          .orderBy('scheduledAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => MeetingModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw MeetingException(e.toString());
    }
  }

  @override
  Future<MeetingModel> joinMeeting({
    required String meetingId,
    required String userId,
    String? password,
  }) async {
    try {
      final meetingRef = _firebaseFirestore
          .collection(AppConstants.meetingsCollection)
          .doc(meetingId);

      final meetingDoc = await meetingRef.get();

      if (!meetingDoc.exists) {
        throw const MeetingException('Meeting not found');
      }

      final meetingData = meetingDoc.data()!;
      final meeting = MeetingModel.fromJson({
        'id': meetingDoc.id,
        ...meetingData,
      });

      // Check password if required
      if (meeting.password != null && meeting.password != password) {
        throw const MeetingException('Invalid meeting password');
      }

      // Add user to participants if not already present
      final participantIds = List<String>.from(meeting.participantIds);
      if (!participantIds.contains(userId)) {
        participantIds.add(userId);

        await meetingRef.update({
          'participantIds': participantIds,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }

      return meeting.copyWith(
        participantIds: participantIds,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      if (e is MeetingException) rethrow;
      throw MeetingException(e.toString());
    }
  }

  @override
  Future<void> leaveMeeting({
    required String meetingId,
    required String userId,
  }) async {
    try {
      final meetingRef = _firebaseFirestore
          .collection(AppConstants.meetingsCollection)
          .doc(meetingId);

      final meetingDoc = await meetingRef.get();

      if (!meetingDoc.exists) {
        throw const MeetingException('Meeting not found');
      }

      final participantIds = List<String>.from(
        meetingDoc.data()!['participantIds'],
      );
      participantIds.remove(userId);

      await meetingRef.update({
        'participantIds': participantIds,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (e is MeetingException) rethrow;
      throw MeetingException(e.toString());
    }
  }

  @override
  Future<MeetingModel> updateMeeting({
    required String meetingId,
    String? title,
    String? description,
    DateTime? scheduledAt,
    int? durationInMinutes,
    String? password,
    bool? isRecordingEnabled,
  }) async {
    try {
      final meetingRef = _firebaseFirestore
          .collection(AppConstants.meetingsCollection)
          .doc(meetingId);

      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (scheduledAt != null)
        updateData['scheduledAt'] = scheduledAt.toIso8601String();
      if (durationInMinutes != null)
        updateData['durationInMinutes'] = durationInMinutes;
      if (password != null) updateData['password'] = password;
      if (isRecordingEnabled != null)
        updateData['isRecordingEnabled'] = isRecordingEnabled;

      await meetingRef.update(updateData);

      final meetingDoc = await meetingRef.get();

      return MeetingModel.fromJson({
        'id': meetingDoc.id,
        ...meetingDoc.data()!,
      });
    } catch (e) {
      throw MeetingException(e.toString());
    }
  }

  @override
  Future<void> deleteMeeting({required String meetingId}) async {
    try {
      await _firebaseFirestore
          .collection(AppConstants.meetingsCollection)
          .doc(meetingId)
          .delete();
    } catch (e) {
      throw MeetingException(e.toString());
    }
  }

  @override
  Future<void> endMeeting({required String meetingId}) async {
    try {
      await _firebaseFirestore
          .collection(AppConstants.meetingsCollection)
          .doc(meetingId)
          .update({
            'status': MeetingStatus.ended.name,
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw MeetingException(e.toString());
    }
  }

  @override
  Stream<MeetingModel> watchMeeting({required String meetingId}) {
    return _firebaseFirestore
        .collection(AppConstants.meetingsCollection)
        .doc(meetingId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            throw const MeetingException('Meeting not found');
          }

          return MeetingModel.fromJson({'id': doc.id, ...doc.data()!});
        });
  }
}
