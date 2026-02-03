import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/saint.dart';
import '../../core/models/tag.dart';
import '../tags/tags_repository.dart';
import 'saints_repository.dart';

class SaintEditPage extends StatefulWidget {
  final Saint? saint;

  const SaintEditPage({super.key, this.saint});

  @override
  State<SaintEditPage> createState() => _SaintEditPageState();
}

class _SaintEditPageState extends State<SaintEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _phoneController;
  late TextEditingController _noteController;

  final _saintsRepository = SaintsRepository();
  final _tagsRepository = TagsRepository();

  List<Tag> _allTags = [];
  List<int> _selectedTagIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.saint?.name);
    _cityController = TextEditingController(text: widget.saint?.city);
    _phoneController = TextEditingController(text: widget.saint?.phone);
    _noteController = TextEditingController(text: widget.saint?.note);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final tags = await _tagsRepository.getTags();
      if (widget.saint?.id != null) {
        final selectedTags = await _saintsRepository.getSaintTags(
          widget.saint!.id!,
        );
        _selectedTagIds = selectedTags.map((t) => t.id!).toList();
      }
      if (mounted) {
        setState(() {
          _allTags = tags;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final saint = Saint(
        id: widget.saint?.id,
        name: _nameController.text.trim(),
        city: _cityController.text.trim(),
        phone: _phoneController.text.trim(),
        note: _noteController.text.trim(),
      );

      int saintId;
      if (widget.saint == null) {
        saintId = await _saintsRepository.createSaint(saint);
      } else {
        saintId = widget.saint!.id!;
        await _saintsRepository.updateSaint(saint);
      }

      await _saintsRepository.updateSaintTags(saintId, _selectedTagIds);

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving saint: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.saint == null ? 'New Saint' : 'Edit Saint'),
        actions: [
          if (widget.saint != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Saint'),
                    content: const Text(
                      'Are you sure you want to delete this member?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _saintsRepository.deleteSaint(widget.saint!.id!);
                  if (context.mounted) {
                    context.pop();
                  }
                }
              },
            ),
        ],
      ),
      body: _isLoading && _allTags.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name *'),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'City'),
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(labelText: 'Note'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _allTags.map((tag) {
                        final isSelected = _selectedTagIds.contains(tag.id);
                        return FilterChip(
                          label: Text(tag.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTagIds.add(tag.id!);
                              } else {
                                _selectedTagIds.remove(tag.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _save,
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
