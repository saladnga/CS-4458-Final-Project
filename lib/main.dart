import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final_project/firebase_options.dart';
import 'package:flutter_final_project/model/field_log.dart';
import 'package:flutter_final_project/screens/home_shell.dart';
import 'package:flutter_final_project/screens/log_detail_screen.dart';
import 'package:provider/provider.dart';
import 'state/field_log_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import './screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FieldLogsApp());
}

class FieldLogsApp extends StatelessWidget {
  const FieldLogsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          FieldLogController(userId: FirebaseAuth.instance.currentUser!.uid)
            ..refresh(),
      child: MaterialApp(
        title: 'Field Logs App',
        theme: ThemeData.dark(),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthGate(),
          '/home': (context) => const HomeShell(),
          '/detail': (context) {
            final log = ModalRoute.of(context)!.settings.arguments as FieldLog;
            return LogDetailScreen(log: log);
          },
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
