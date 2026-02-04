import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/tag.dart';
import 'tags_repository.dart';

class TagEditPage extends StatefulWidget {
  final Tag? tag;

  const TagEditPage({super.key, this.tag});

  @override
  State<TagEditPage> createState() => _TagEditPageState();
}

class _TagEditPageState extends State<TagEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  TagType _selectedType = TagType.saints;
  final _repository = TagsRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.tag != null) {
      _nameController.text = widget.tag!.name;
      _selectedType = widget.tag!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveTag() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final tag = Tag(
        id: widget.tag?.id,
        name: _nameController.text.trim(),
        type: _selectedType,
      );

      if (widget.tag == null) {
        await _repository.createTag(tag);
      } else {
        await _repository.updateTag(tag);
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving tag: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tag == null ? 'New Tag' : 'Edit Tag'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _saveTag,
        icon: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
        label: Text(_isLoading ? 'Saving...' : 'Save Tag'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tag Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter tag name',
                  border: OutlineInputBorder(),
                  filled: true,
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Tag Type',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<TagType>(
                segments: const [
                  ButtonSegment<TagType>(
                    value: TagType.saints,
                    label: Text('Saints'),
                    icon: Icon(Icons.person_outline),
                  ),
                  ButtonSegment<TagType>(
                    value: TagType.meeting,
                    label: Text('Meeting'),
                    icon: Icon(Icons.event_outlined),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<TagType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.comfortable,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }
}
