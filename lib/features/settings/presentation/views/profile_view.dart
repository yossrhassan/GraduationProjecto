import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.green,
            child: Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 48),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          child: const Icon(Icons.person,
                              size: 60, color: Colors.grey),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 20),
                            onPressed: () {
                              // TODO: Implement profile picture change
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'John Doe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'john.doe@example.com',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                const SizedBox(height: 8),
                const Text(
                  'ACCOUNT SETTINGS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: const Color(0xFF18191A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.green),
                    title: const Text('Edit Profile',
                        style: TextStyle(color: Colors.white)),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.white54),
                    onTap: () {
                      // TODO: Navigate to Edit Profile
                    },
                  ),
                ),
                Card(
                  color: const Color(0xFF18191A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.lock, color: Colors.green),
                    title: const Text('Change Password',
                        style: TextStyle(color: Colors.white)),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.white54),
                    onTap: () {
                      // TODO: Navigate to Change Password
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'DANGER ZONE',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: const Color(0xFF18191A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Delete Account',
                        style: TextStyle(color: Colors.red)),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.white54),
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Account'),
                          content: const Text(
                              'Are you sure you want to delete your account? This action cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        // TODO: Implement account deletion
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text('Log Out',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Log Out'),
                          content:
                              const Text('Are you sure you want to log out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Log Out',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        // TODO: Implement logout
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
