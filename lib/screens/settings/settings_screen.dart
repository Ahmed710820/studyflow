import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Initialize once at the top of the file
final FlutterLocalNotificationsPlugin _notificationsPlugin =
    FlutterLocalNotificationsPlugin();

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);

  await _notificationsPlugin.initialize(initSettings);
}
  Future<void> _toggleNotifications(bool value) async {
  setState(() => _notificationsEnabled = value);

  final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  if (value) {
    await androidPlugin?.requestNotificationsPermission();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'studyflow_channel',
      'StudyFlow Reminders',
      channelDescription: 'Deadline and study reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      'Notifications Enabled',
      'You will now receive study reminders.',
      notificationDetails,
    );
  } else {
    await _notificationsPlugin.cancelAll();
  }
}

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ── Profile Card ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        (user?.email ?? 'S')[0].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.email ?? 'Student',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 15)),
                        const Text('StudyFlow account',
                            style: TextStyle(
                                color: AppColors.gray, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text('Preferences',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray,
                    fontWeight: FontWeight.w500)),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark mode'),
                  subtitle: const Text('Follows system setting',
                      style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.info_outline,
                      size: 16, color: AppColors.gray),
                ),
                const Divider(height: 0),
                // ── Fixed notifications toggle ────────────────────────────
                ListTile(
                  leading: Icon(
                    _notificationsEnabled
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                    color: _notificationsEnabled
                        ? AppColors.primary
                        : AppColors.gray,
                  ),
                  title: const Text('Notifications'),
                  subtitle: Text(
                    _notificationsEnabled
                        ? 'Deadline & study reminders active'
                        : 'All reminders are paused',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,  // ← actually connected now
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('About',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray,
                    fontWeight: FontWeight.w500)),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  trailing: Text('1.0.0',
                      style: TextStyle(color: AppColors.gray, fontSize: 13)),
                ),
                const Divider(height: 0),
                const ListTile(
                  leading: Icon(Icons.school_outlined),
                  title: Text('StudyFlow'),
                  subtitle: Text('Intelligent Academic Task Management',
                      style: TextStyle(fontSize: 12)),
                ),
                const Divider(height: 0),
                const ListTile(
                  leading: Icon(Icons.people_outline),
                  title: Text('Team'),
                  subtitle: Text('Mohyeddine & Ahmed',
                      style: TextStyle(fontSize: 12)),
                  trailing: Text('Flutter 3.41 · Dart 3.11',
                      style: TextStyle(color: AppColors.gray, fontSize: 11)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => AuthService().signOut(),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sign out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}