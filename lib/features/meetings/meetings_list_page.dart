import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/models/meeting.dart';
import 'meetings_repository.dart';

class MeetingsListPage extends StatefulWidget {
  const MeetingsListPage({super.key});

  @override
  State<MeetingsListPage> createState() => _MeetingsListPageState();
}

class _MeetingsListPageState extends State<MeetingsListPage> {
  final _repository = MeetingsRepository();
  List<Meeting> _meetings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMeetings();
  }

  Future<void> _loadMeetings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final meetings = await _repository.getMeetings();
      if (mounted) {
        setState(() {
          _meetings = meetings;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meetings')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/meetings/new'),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : _meetings.isEmpty
          ? const Center(child: Text('No meetings found'))
          : ListView.builder(
              itemCount: _meetings.length,
              itemBuilder: (context, index) {
                final meeting = _meetings[index];
                final dateStr = meeting.meetingDate != null
                    ? DateFormat.yMMMd().format(meeting.meetingDate!)
                    : 'No date';
                return ListTile(
                  title: Text(meeting.name),
                  subtitle: Text(dateStr),
                  onTap: () =>
                      context.go('/meetings/${meeting.id}', extra: meeting),
                );
              },
            ),
    );
  }
}
