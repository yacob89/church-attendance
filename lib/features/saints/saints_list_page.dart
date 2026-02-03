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
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saints'),
        centerTitle: false,
      ),
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
                  : _saints.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.people_outline,
                                        size: 64,
                                        color: theme.colorScheme.secondary),
                                    const SizedBox(height: 16),
                                    Text('No saints found',
                                        style: theme.textTheme.titleMedium),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _saints.length,
                          itemBuilder: (context, index) {
                            final saint = _saints[index];
                            final initials = saint.name.isNotEmpty
                                ? saint.name.trim().split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase()
                                : '?';
                            
                            // Generate a stable color from the name
                            final colorSeed = saint.name.codeUnits.fold(0, (p, c) => p + c);
                            final avatarColor = Colors.primaries[colorSeed % Colors.primaries.length];

                            return Card(
                              elevation: 0,
                              color: theme.colorScheme.surfaceContainer,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 0),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: avatarColor.withOpacity(0.2),
                                  foregroundColor: avatarColor,
                                  child: Text(initials,
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                title: Text(
                                  saint.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      if (saint.city != null && saint.city!.isNotEmpty) ...[
                                        Icon(Icons.location_on_outlined,
                                            size: 14,
                                            color: theme.colorScheme.secondary),
                                        const SizedBox(width: 4),
                                        Text(saint.city!,
                                            style: theme.textTheme.bodySmall),
                                        const SizedBox(width: 12),
                                      ],
                                      if (saint.phone != null && saint.phone!.isNotEmpty) ...[
                                        Icon(Icons.phone_outlined,
                                            size: 14,
                                            color: theme.colorScheme.secondary),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(saint.phone!,
                                              style: theme.textTheme.bodySmall,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                trailing: Icon(Icons.chevron_right,
                                    color: theme.colorScheme.onSurfaceVariant),
                                onTap: () async {
                                  await context.push(
                                    '/saints/${saint.id}',
                                    extra: saint,
                                  );
                                  _loadSaints(showLoading: false);
                                },
                              ),
                            );
                          },
                        ),
            ),
    );
  }
}
