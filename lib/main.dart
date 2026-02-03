import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/supabase_constants.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/dashboard/scaffold_with_navbar.dart';
import 'features/tags/tags_list_page.dart';
import 'features/tags/tag_edit_page.dart';
import 'features/saints/saints_list_page.dart';
import 'features/saints/saint_edit_page.dart';
import 'features/meetings/meetings_list_page.dart';
import 'features/meetings/meeting_edit_page.dart';
import 'core/models/tag.dart';
import 'core/models/saint.dart';
import 'core/models/meeting.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (AuthState _) => notifyListeners(),
    );
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  refreshListenable: GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Home Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardPage(),
            ),
          ],
        ),
        // Saints Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/saints',
              builder: (context, state) => const SaintsListPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const SaintEditPage(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final saint = state.extra as Saint?;
                    return SaintEditPage(saint: saint);
                  },
                ),
              ],
            ),
          ],
        ),
        // Meetings Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/meetings',
              builder: (context, state) => const MeetingsListPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const MeetingEditPage(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final meeting = state.extra as Meeting?;
                    return MeetingEditPage(meeting: meeting);
                  },
                ),
              ],
            ),
          ],
        ),
        // Tags Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tags',
              builder: (context, state) => const TagsListPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const TagEditPage(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final tag = state.extra as Tag?;
                    return TagEditPage(tag: tag);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final loggingIn = state.matchedLocation == '/login';

    if (session == null && !loggingIn) {
      return '/login';
    }
    if (session != null && loggingIn) {
      return '/';
    }
    return null;
  },
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Church Attendance',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        context.go('/');
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unexpected error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _signIn,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
