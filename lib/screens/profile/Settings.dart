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
              onTap: () {},
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
              subtitle: const Text("Add or update delivery addresses"),
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
          SwitchListTile(
            value: true,
            onChanged: (value) {},
            secondary: const Icon(Icons.notifications, color: Colors.blue),
            title: const Text("Push Notifications"),
            subtitle: const Text("Get updates about orders & offers"),
          ),
          SwitchListTile(
            value: false,
            onChanged: (value) {},
            secondary: const Icon(Icons.dark_mode, color: Colors.purple),
            title: const Text("Dark Mode"),
            subtitle: const Text("Enable dark theme for the app"),
          ),

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
                Navigator.pushNamed(context, "/help");
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.blueGrey),
              title: const Text("About FreshCart"),
              subtitle: const Text("Learn more about this app"),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
