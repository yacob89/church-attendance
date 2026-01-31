import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/tag.dart';
import 'tags_repository.dart';

class TagsListPage extends StatefulWidget {
  const TagsListPage({super.key});

  @override
  State<TagsListPage> createState() => _TagsListPageState();
}

class _TagsListPageState extends State<TagsListPage> {
  final _repository = TagsRepository();
  List<Tag> _tags = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final tags = await _repository.getTags();
      if (mounted) {
        setState(() {
          _tags = tags;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteTag(int id) async {
    try {
      await _repository.deleteTag(id);
      _loadTags();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting tag: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tags')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/tags/new'),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : _tags.isEmpty
          ? const Center(child: Text('No tags found'))
          : ListView.builder(
              itemCount: _tags.length,
              itemBuilder: (context, index) {
                final tag = _tags[index];
                return ListTile(
                  title: Text(tag.name),
                  subtitle: Text(tag.type),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteTag(tag.id!),
                  ),
                  onTap: () => context.go('/tags/${tag.id}', extra: tag),
                );
              },
            ),
    );
  }
}
