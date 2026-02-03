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
    final theme = Theme.of(context);
    
    // Group tags
    final saintsTags = _tags.where((t) => t.type == TagType.saints).toList();
    final meetingTags = _tags.where((t) => t.type == TagType.meeting).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
        centerTitle: false,
      ),
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
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 48, color: theme.colorScheme.error),
                                const SizedBox(height: 16),
                                Text('Error: $_error',
                                    style: theme.textTheme.bodyLarge),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : _tags.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.label_off,
                                        size: 64,
                                        color: theme.colorScheme.secondary),
                                    const SizedBox(height: 16),
                                    Text('No tags found',
                                        style: theme.textTheme.titleMedium),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          children: [
                            if (saintsTags.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Saints Tags',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ...saintsTags.map((tag) => _buildTagItem(context, tag, theme)),
                              const SizedBox(height: 16),
                            ],
                            if (meetingTags.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Meeting Tags',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ...meetingTags.map((tag) => _buildTagItem(context, tag, theme)),
                            ],
                          ],
                        ),
            ),
    );
  }

  Widget _buildTagItem(BuildContext context, Tag tag, ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          tag.type == TagType.saints ? Icons.person_outline : Icons.event,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          tag.name,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          color: theme.colorScheme.onSurfaceVariant,
          onPressed: () => _deleteTag(tag.id!),
        ),
        onTap: () async {
          await context.push('/tags/${tag.id}', extra: tag);
          _loadTags(showLoading: false);
        },
      ),
    );
  }
}
