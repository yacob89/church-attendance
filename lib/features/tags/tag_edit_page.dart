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
  final _typeController = TextEditingController();
  final _repository = TagsRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.tag != null) {
      _nameController.text = widget.tag!.name;
      _typeController.text = widget.tag!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _saveTag() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final tag = Tag(
        id: widget.tag?.id,
        name: _nameController.text.trim(),
        type: _typeController.text.trim(),
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.tag == null ? 'New Tag' : 'Edit Tag')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Type (e.g., status, role)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveTag,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
