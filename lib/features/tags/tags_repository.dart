import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/tag.dart';

class TagsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Tag>> getTags() async {
    final response = await _client.from('tags').select().order('name');
    final data = response as List<dynamic>;
    return data.map((json) => Tag.fromJson(json)).toList();
  }

  Future<void> createTag(Tag tag) async {
    await _client.from('tags').insert(tag.toJson());
  }

  Future<void> updateTag(Tag tag) async {
    if (tag.id == null) throw Exception('Tag ID is required for update');
    await _client.from('tags').update(tag.toJson()).eq('id', tag.id!);
  }

  Future<void> deleteTag(int id) async {
    await _client.from('tags').delete().eq('id', id);
  }
}
