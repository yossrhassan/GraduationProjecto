import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/settings/data/models/user_model.dart';
import 'package:graduation_project/features/settings/presentation/manager/settings_cubit.dart';
import 'package:graduation_project/features/settings/presentation/manager/settings_state.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!hasLoaded) {
      final userId = AuthManager.userId;
      if (userId != null) {
        context.read<SettingsCubit>().loadUserProfile(userId);
        hasLoaded = true;
      } else {
        debugPrint('⚠️ AuthManager.userId is null');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: const Text('Profile'),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SettingsLoaded) {
            return _buildProfile(context, state.user);
          } else if (state is SettingsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildProfile(BuildContext context, UserModel user) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.green,
          child: Column(
            children: [
              const SizedBox(height: 24), // Space below AppBar
              CircleAvatar(
                radius: 54,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[400],
                  child:
                      const Icon(Icons.person, size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24), // Space below avatar
            ],
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
                    context.pushNamed('editProfile', extra: user);
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
                    context.pushNamed('changePassword');
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Delete Account (red card)
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
              // Log Out (red button)
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
                      await AuthManager.clearAuthToken();
                      await AuthManager.clearUserId();
                      if (context.mounted) {
                        context.go(AppRouter.kLoginView);
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
