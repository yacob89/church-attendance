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

  Future<void> _loadTags({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
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
      _loadTags(showLoading: false);
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
        onPressed: () async {
          await context.push('/tags/new');
          _loadTags(showLoading: false);
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadTags(showLoading: false),
              child: _error != null
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Center(child: Text('Error: $_error')),
                        ),
                      ],
                    )
                  : _tags.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: const Center(child: Text('No tags found')),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                          onTap: () async {
                            await context.push('/tags/${tag.id}', extra: tag);
                            _loadTags(showLoading: false);
                          },
                        );
                      },
                    ),
            ),
    );
  }
}
