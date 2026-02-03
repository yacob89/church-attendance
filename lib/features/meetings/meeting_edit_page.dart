import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/models/meeting.dart';
import '../../core/models/saint.dart';
import '../saints/saints_repository.dart';
import 'meetings_repository.dart';

class MeetingEditPage extends StatefulWidget {
  final Meeting? meeting;

  const MeetingEditPage({super.key, this.meeting});

  @override
  State<MeetingEditPage> createState() => _MeetingEditPageState();
}

class _MeetingEditPageState extends State<MeetingEditPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Details Tab
  late TextEditingController _nameController;
  late TextEditingController _dateController;
  late TextEditingController _noteController;
  DateTime? _selectedDate;

  // Attendance Tab
  List<Saint> _allSaints = [];
  List<int> _attendedSaintIds = [];
  String _filter = '';

  final _meetingsRepository = MeetingsRepository();
  final _saintsRepository = SaintsRepository();

  bool _isLoading = false;
  bool _isNew = true;

  @override
  void initState() {
    super.initState();
    _isNew = widget.meeting == null;
    _tabController = TabController(length: _isNew ? 1 : 2, vsync: this);

    _nameController = TextEditingController(text: widget.meeting?.name);
    _noteController = TextEditingController(text: widget.meeting?.note);
    _selectedDate = widget.meeting?.meetingDate;
    _dateController = TextEditingController(
      text: _selectedDate != null
          ? DateFormat.yMMMd().format(_selectedDate!)
          : '',
    );

    if (!_isNew) {
      _loadAttendanceData();
    }
  }

  Future<void> _loadAttendanceData() async {
    setState(() => _isLoading = true);
    try {
      final saints = await _saintsRepository.getSaints();
      final attendance = await _meetingsRepository.getMeetingAttendance(
        widget.meeting!.id!,
      );

      if (mounted) {
        setState(() {
          _allSaints = saints;
          _attendedSaintIds = attendance;
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
    _tabController.dispose();
    _nameController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat.yMMMd().format(picked);
      });
    }
  }

  Future<void> _saveDetails() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a date')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final meeting = Meeting(
        id: widget.meeting?.id,
        name: _nameController.text.trim(),
        meetingDate: _selectedDate,
        note: _noteController.text.trim(),
      );

      if (_isNew) {
        await _meetingsRepository.createMeeting(meeting);
        if (mounted) {
          // Navigate to self with ID to enable attendance tab
          // ideally we replace the route, but for now going back is safer
          context.pop();
        }
      } else {
        await _meetingsRepository.updateMeeting(meeting);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Meeting updated')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveAttendance() async {
    if (_isNew) return;
    setState(() => _isLoading = true);
    try {
      await _meetingsRepository.updateAttendance(
        widget.meeting!.id!,
        _attendedSaintIds,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Attendance saved')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving attendance: $e')));
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
        title: Text(_isNew ? 'New Meeting' : 'Edit Meeting'),
        bottom: _isNew
            ? null
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Details'),
                  Tab(text: 'Attendance'),
                ],
              ),
        actions: [
          if (!_isNew)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Meeting'),
                    content: const Text('Are you sure?'),
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
                  await _meetingsRepository.deleteMeeting(widget.meeting!.id!);
                  if (context.mounted) context.pop();
                }
              },
            ),
        ],
      ),
      body: _isLoading && _allSaints.isEmpty && !_isNew
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Details
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name *',
                          ),
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            labelText: 'Date *',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: _pickDate,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _noteController,
                          decoration: const InputDecoration(labelText: 'Note'),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _saveDetails,
                          child: Text(
                            _isNew ? 'Create Meeting' : 'Update Details',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab 2: Attendance (Only if not new)
                if (!_isNew)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Search Saints',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) =>
                              setState(() => _filter = val.toLowerCase()),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _allSaints.length,
                          itemBuilder: (context, index) {
                            final saint = _allSaints[index];
                            if (_filter.isNotEmpty &&
                                !saint.name.toLowerCase().contains(_filter)) {
                              return const SizedBox.shrink();
                            }

                            final isPresent = _attendedSaintIds.contains(
                              saint.id,
                            );
                            return CheckboxListTile(
                              title: Text(saint.name),
                              subtitle: saint.city != null
                                  ? Text(saint.city!)
                                  : null,
                              value: isPresent,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _attendedSaintIds.add(saint.id!);
                                  } else {
                                    _attendedSaintIds.remove(saint.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveAttendance,
                            child: const Text('Save Attendance'),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  const Center(child: Text('Create meeting first')),
              ],
            ),
    );
  }
}
