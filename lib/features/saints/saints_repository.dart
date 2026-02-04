import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/saint.dart';
import '../../core/models/tag.dart';

class SaintsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Saint>> getSaints() async {
    final response = await _client
        .from('saints')
        .select('*, saints_tags(tags(*))')
        .order('name');
    final data = response as List<dynamic>;
    return data.map((json) => Saint.fromJson(json)).toList();
  }

  Future<int> createSaint(Saint saint) async {
    final response = await _client
        .from('saints')
        .insert(saint.toJson())
        .select('id')
        .single();
    return response['id'] as int;
  }

  Future<void> updateSaint(Saint saint) async {
    if (saint.id == null) throw Exception('Saint ID is required for update');
    await _client.from('saints').update(saint.toJson()).eq('id', saint.id!);
  }

  Future<void> deleteSaint(int id) async {
    await _client.from('saints').delete().eq('id', id);
  }

  // Tags Management for Saints
  Future<List<Tag>> getSaintTags(int saintId) async {
    final response = await _client
        .from('saints_tags')
        .select('tags (*)')
        .eq('saints_id', saintId);

    final data = response as List<dynamic>;
    return data
        .map((item) => Tag.fromJson(item['tags'] as Map<String, dynamic>))
        .toList();
  }

  Future<void> addTagToSaint(int saintId, int tagId) async {
    await _client.from('saints_tags').insert({
      'saints_id': saintId,
      'tags_id': tagId,
    });
  }

  Future<void> removeTagFromSaint(int saintId, int tagId) async {
    await _client
        .from('saints_tags')
        .delete()
        .eq('saints_id', saintId)
        .eq('tags_id', tagId);
  }

  Future<void> updateSaintTags(int saintId, List<int> tagIds) async {
    // A simple way to update is to delete all and re-add
    // In a production app, you'd find the delta
    await _client.from('saints_tags').delete().eq('saints_id', saintId);
    if (tagIds.isNotEmpty) {
      final inserts = tagIds
          .map((tid) => {'saints_id': saintId, 'tags_id': tid})
          .toList();
      await _client.from('saints_tags').insert(inserts);
    }
  }
}
