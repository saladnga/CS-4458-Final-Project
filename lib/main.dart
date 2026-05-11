import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final_project/firebase_options.dart';
import 'package:flutter_final_project/screens/home_shell.dart';
import 'package:flutter_final_project/screens/profile_screen.dart';
import 'package:flutter_final_project/state/theme_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'state/field_log_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import './screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final themeController = ThemeController(prefs)..loadSaved();

  runApp(
    ChangeNotifierProvider<ThemeController>.value(
      value: themeController,
      child: const FieldLogsApp(),
    ),
  );
}

class FieldLogsApp extends StatelessWidget {
  const FieldLogsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, theme, _) => MaterialApp(
        title: 'Field Logs App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        darkTheme: ThemeData.dark(),
        themeMode: theme.themeMode,
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthGate(),
          '/home': (context) => const HomeShell(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user != null) {
          return ChangeNotifierProvider(
            key: ValueKey(user.uid),
            create: (_) => FieldLogController(userId: user.uid)..refresh(),
            child: const HomeShell(),
          );
        }
        return const AuthScreen();
      },
    );
  }
}
