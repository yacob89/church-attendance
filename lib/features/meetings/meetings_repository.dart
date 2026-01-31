import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/meeting.dart';

class MeetingsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Meeting>> getMeetings() async {
    final response = await _client
        .from('meetings')
        .select()
        .order('meeting_date', ascending: false);
    final data = response as List<dynamic>;
    return data.map((json) => Meeting.fromJson(json)).toList();
  }

  Future<int> createMeeting(Meeting meeting) async {
    final response = await _client
        .from('meetings')
        .insert(meeting.toJson())
        .select('id')
        .single();
    return response['id'] as int;
  }

  Future<void> updateMeeting(Meeting meeting) async {
    if (meeting.id == null) {
      throw Exception('Meeting ID is required for update');
    }
    await _client
        .from('meetings')
        .update(meeting.toJson())
        .eq('id', meeting.id!);
  }

  Future<void> deleteMeeting(int id) async {
    await _client.from('meetings').delete().eq('id', id);
  }

  // Attendance Management

  // Get list of Saint IDs who attended the meeting
  Future<List<int>> getMeetingAttendance(int meetingId) async {
    final response = await _client
        .from('meetings_attendance')
        .select('saints_id')
        .eq('meetings_id', meetingId);

    final data = response as List<dynamic>;
    return data.map((item) => item['saints_id'] as int).toList();
  }

  Future<void> updateAttendance(int meetingId, List<int> saintIds) async {
    // Similar strategy: clear and re-insert for simplicity.
    // In production with huge datasets, you'd optimize this.
    await _client
        .from('meetings_attendance')
        .delete()
        .eq('meetings_id', meetingId);

    if (saintIds.isNotEmpty) {
      final inserts = saintIds
          .map((sid) => {'meetings_id': meetingId, 'saints_id': sid})
          .toList();
      await _client.from('meetings_attendance').insert(inserts);
    }
  }
}
