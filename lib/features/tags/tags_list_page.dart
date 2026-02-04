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

  Future<void> _confirmDelete(Tag tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text('Are you sure you want to delete "${tag.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && tag.id != null) {
      _deleteTag(tag.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Group and sort tags
    final saintsTags = _tags.where((t) => t.type == TagType.saints).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final meetingTags = _tags.where((t) => t.type == TagType.meeting).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tags'),
          centerTitle: false,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Saints'),
              Tab(text: 'Meetings'),
            ],
          ),
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
            : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: $_error', style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => _loadTags(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : TabBarView(
                children: [
                  _buildTagList(
                    context,
                    saintsTags,
                    'No saints tags found',
                    theme,
                  ),
                  _buildTagList(
                    context,
                    meetingTags,
                    'No meeting tags found',
                    theme,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTagList(
    BuildContext context,
    List<Tag> tags,
    String emptyMessage,
    ThemeData theme,
  ) {
    return RefreshIndicator(
      onRefresh: () => _loadTags(showLoading: false),
      child: tags.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.label_off,
                          size: 64,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(height: 16),
                        Text(emptyMessage, style: theme.textTheme.titleMedium),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tags.length,
              itemBuilder: (context, index) {
                return _buildTagItem(context, tags[index], theme);
              },
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
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          color: theme.colorScheme.onSurfaceVariant,
          onPressed: () => _confirmDelete(tag),
        ),
        onTap: () async {
          await context.push('/tags/${tag.id}', extra: tag);
          _loadTags(showLoading: false);
        },
      ),
    );
  }
}
