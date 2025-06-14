import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';
import 'package:graduation_project/features/settings/data/models/user_model.dart';
import 'package:graduation_project/features/settings/presentation/manager/settings_cubit.dart';
import 'package:graduation_project/features/settings/presentation/manager/settings_state.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool hasLoaded = false;

  @override
  void initState() {
    super.initState();
    print('🎬 ProfileView initState - userId: ${AuthManager.userId}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print(
        '🔄 ProfileView: didChangeDependencies called, hasLoaded: $hasLoaded');
    if (!hasLoaded) {
      final userId = AuthManager.userId;
      print('📱 ProfileView: Retrieved userId: $userId');
      if (userId != null) {
        print('🚀 ProfileView: Loading user profile for userId: $userId');
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
        title: const Text('Profile'),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SettingsLoaded) {
            return _buildProfile(context, state.user);
          } else if (state is SettingsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}',
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  Text('UserId: ${AuthManager.userId}',
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('UserId: ${AuthManager.userId}',
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfile(BuildContext context, UserModel user) {
    final displayName = (user.firstName.isEmpty && user.lastName.isEmpty)
        ? 'User Name'
        : '${user.firstName} ${user.lastName}';
    final displayEmail = user.email.isEmpty ? 'No email provided' : user.email;

    print(
        '🎯 _buildProfile called with user: firstName="${user.firstName}", lastName="${user.lastName}", email="${user.email}"');

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.green,
          child: Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 48),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 54,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child:
                        const Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayEmail,
                  style: const TextStyle(
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
                    GoRouter.of(context)
                        .push(AppRouter.kEditProfileView, extra: user);
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
                      await AuthManager.clearAuthToken();
                      await AuthManager.clearUserId();
                      if (context.mounted) {
                        GoRouter.of(context).go(AppRouter.kLoginView);
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
