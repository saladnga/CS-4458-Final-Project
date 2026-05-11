import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final_project/screens/profile_screen.dart';
import 'package:flutter_final_project/state/theme_controller.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
            color: Theme.of(context).primaryColor,
            child: const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Consumer<ThemeController>(
            builder: (context, tc, _) {
              final isLight = tc.themeMode == ThemeMode.light;
              return SwitchListTile(
                secondary: Icon(
                  isLight
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
                title: const Text('Change Theme'),
                value: isLight,
                onChanged: (enabled) {
                  tc.setThemeMode(enabled ? ThemeMode.light : ThemeMode.dark);
                },
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
