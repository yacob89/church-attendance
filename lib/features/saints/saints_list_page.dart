import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/saint.dart';
import '../../core/models/tag.dart';
import '../tags/tags_repository.dart';
import 'saints_repository.dart';

class SaintsListPage extends StatefulWidget {
  const SaintsListPage({super.key});

  @override
  State<SaintsListPage> createState() => _SaintsListPageState();
}

class _SaintsListPageState extends State<SaintsListPage> {
  final _repository = SaintsRepository();
  final _tagsRepository = TagsRepository();
  List<Saint> _saints = [];
  List<Tag> _availableTags = [];
  List<int> _selectedTagIds = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final results = await Future.wait([
        _repository.getSaints(),
        _tagsRepository.getTags(),
      ]);

      final saints = results[0] as List<Saint>;
      final tags = results[1] as List<Tag>;

      // Sort saints alphabetically by name
      saints.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      if (mounted) {
        setState(() {
          _saints = saints;
          _availableTags = tags.where((t) => t.type == TagType.saints).toList();
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

  List<Saint> get _filteredSaints {
    if (_selectedTagIds.isEmpty) {
      return _saints;
    }
    return _saints.where((s) {
      final saintTagIds = s.tags.map((t) => t.id).toSet();
      return _selectedTagIds.every((id) => saintTagIds.contains(id));
    }).toList();
  }

  Future<void> _showFilterDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        List<int> tempSelectedTagIds = List.from(_selectedTagIds);

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter by Tag'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('All Saints'),
                            selected: tempSelectedTagIds.isEmpty,
                            onSelected: (selected) {
                              setState(() {
                                tempSelectedTagIds.clear();
                              });
                            },
                          ),
                          ..._availableTags.map((tag) {
                            final isSelected = tempSelectedTagIds.contains(
                              tag.id,
                            );
                            return FilterChip(
                              label: Text(tag.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    tempSelectedTagIds.add(tag.id!);
                                  } else {
                                    tempSelectedTagIds.remove(tag.id);
                                  }
                                });
                              },
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Apply'),
                  onPressed: () {
                    this.setState(() {
                      _selectedTagIds = tempSelectedTagIds;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayedSaints = _filteredSaints;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saints'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              _selectedTagIds.isEmpty
                  ? Icons.filter_list
                  : Icons.filter_list_alt,
              color: _selectedTagIds.isNotEmpty
                  ? theme.colorScheme.primary
                  : null,
            ),
            tooltip: 'Filter by tag',
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/saints/new');
          _loadData(showLoading: false);
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadData(showLoading: false),
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
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error: $_error',
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : displayedSaints.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: theme.colorScheme.secondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedTagIds.isNotEmpty
                                      ? 'No saints found with these tags'
                                      : 'No saints found',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: displayedSaints.length,
                      itemBuilder: (context, index) {
                        final saint = displayedSaints[index];
                        final initials = saint.name.isNotEmpty
                            ? saint.name
                                  .trim()
                                  .split(' ')
                                  .take(2)
                                  .map((e) => e.isNotEmpty ? e[0] : '')
                                  .join()
                                  .toUpperCase()
                            : '?';

                        // Generate a stable color from the name
                        final colorSeed = saint.name.codeUnits.fold(
                          0,
                          (p, c) => p + c,
                        );
                        final avatarColor = Colors
                            .primaries[colorSeed % Colors.primaries.length];

                        return Card(
                          elevation: 0,
                          color: theme.colorScheme.surfaceContainer,
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 0,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: avatarColor.withOpacity(0.2),
                              foregroundColor: avatarColor,
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              saint.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: saint.tags.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: saint.tags.map((tag) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme
                                                .colorScheme
                                                .secondaryContainer,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            tag.name,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSecondaryContainer,
                                                ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  )
                                : null,
                            trailing: Icon(
                              Icons.chevron_right,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            onTap: () async {
                              await context.push(
                                '/saints/${saint.id}',
                                extra: saint,
                              );
                              _loadData(showLoading: false);
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
