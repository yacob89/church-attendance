import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/saint.dart';
import 'saints_repository.dart';

class SaintsListPage extends StatefulWidget {
  const SaintsListPage({super.key});

  @override
  State<SaintsListPage> createState() => _SaintsListPageState();
}

class _SaintsListPageState extends State<SaintsListPage> {
  final _repository = SaintsRepository();
  List<Saint> _saints = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSaints();
  }

  Future<void> _loadSaints({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final saints = await _repository.getSaints();
      if (mounted) {
        setState(() {
          _saints = saints;
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
      appBar: AppBar(title: const Text('Saints')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/saints/new');
          _loadSaints(showLoading: false);
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadSaints(showLoading: false),
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
                  : _saints.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: const Center(child: Text('No saints found')),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _saints.length,
                      itemBuilder: (context, index) {
                        final saint = _saints[index];
                        return ListTile(
                          title: Text(saint.name),
                          subtitle: Text(saint.city ?? 'No city'),
                          onTap: () async {
                            await context.push(
                              '/saints/${saint.id}',
                              extra: saint,
                            );
                            _loadSaints(showLoading: false);
                          },
                        );
                      },
                    ),
            ),
    );
  }
}
