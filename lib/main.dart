import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/session_result.dart';
import 'screens/arena_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/history_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(SessionResultAdapter());
  await Hive.openBox<SessionResult>('history');

  runApp(const ProviderScope(child: ShrutiApp()));
}

class ShrutiApp extends ConsumerWidget {
  const ShrutiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Shruti',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainNavScreen(),
        '/arena': (context) => const ArenaScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [const SetupScreen(), const HistoryScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppTheme.cardColor,
        selectedItemColor: AppTheme.neonCyan,
        unselectedItemColor: Colors.white38,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.gamepad), label: "TRAIN"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "HISTORY"),
        ],
      ),
    );
  }
}
