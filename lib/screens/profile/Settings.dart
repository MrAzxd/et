import 'package:e/screens/profile/AboutFreshcart.dart';
import 'package:e/screens/profile/Editprofile.dart';
import 'package:e/screens/profile/Support_Screen.dart';
import 'package:e/screens/profile/change_password.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          // Profile Settings
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Account Settings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: const Text("Edit Profile"),
              subtitle: const Text("Change your name, phone or photo"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock, color: Colors.orange),
              title: const Text("Change Password"),
              subtitle: const Text("Update your account password"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: const Text("Manage Addresses"),
              subtitle: const Text("Add or update  addresses"),
              onTap: () {},
            ),
          ),

          const SizedBox(height: 20),

          // App Preferences
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "App Preferences",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          AppPreferences(),
          // SwitchListTile(
          //   value: true,
          //   onChanged: (value) {},
          //   secondary: const Icon(Icons.notifications, color: Colors.blue),
          //   title: const Text("Push Notifications"),
          //   subtitle: const Text("Get updates about orders & offers"),
          // ),
          // SwitchListTile(
          //   value: false,
          //   onChanged: (value) {},
          //   secondary: const Icon(Icons.dark_mode, color: Colors.purple),
          //   title: const Text("Dark Mode"),
          //   subtitle: const Text("Enable dark theme for the app"),
          // ),

          const SizedBox(height: 20),

          // Support & About
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Support",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.help, color: Colors.teal),
              title: const Text("Help & Support"),
              subtitle: const Text("Get help with your orders & account"),
              onTap: () {
                // Navigate to HelpSupportScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HelpSupportScreen(),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.blueGrey),
              title: const Text("About FreshCart"),
              subtitle: const Text("Learn more about this app"),
              onTap: () {
                // Navigate to AboutFreshcartScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AboutFreshCartScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AppPreferences extends StatefulWidget {
  const AppPreferences({super.key});

  @override
  State<AppPreferences> createState() => _AppPreferencesState();
}

class _AppPreferencesState extends State<AppPreferences> {
  bool _pushNotifications = true;
  bool _darkMode = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          value: _pushNotifications,
          onChanged: (value) {
            setState(() {
              _pushNotifications = value;
            });
            _showMessage(
              value
                  ? 'You will get notifications on updates!'
                  : 'Notifications turned off',
            );
            // TODO: Add push notification logic here
          },
          secondary: const Icon(Icons.notifications, color: Colors.blue),
          title: const Text("Push Notifications"),
          subtitle: const Text("Get updates about orders & offers"),
        ),
        SwitchListTile(
          value: _darkMode,
          onChanged: (value) {
            setState(() {
              _darkMode = value;
            });
            _showMessage(
              'Dark Mode feature will be added soon!',
            );
            // TODO: Add dark/light theme logic here
          },
          secondary: const Icon(Icons.dark_mode, color: Colors.purple),
          title: const Text("Dark Mode"),
          subtitle: const Text("Enable dark theme for the app"),
        ),
      ],
    );
  }
}
