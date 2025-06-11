import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';
import 'package:graduation_project/core/utils/service_locator.dart';
import 'package:graduation_project/features/settings/data/repos/delete_account_service.dart';

class DeleteAccountView extends StatefulWidget {
  const DeleteAccountView({super.key});

  @override
  State<DeleteAccountView> createState() => _DeleteAccountViewState();
}

class _DeleteAccountViewState extends State<DeleteAccountView> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: const Text('Delete Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWarningCard(),
                  const Text(
                    'Before you delete your account:',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  _DeleteAccountListItem(
                    number: 1,
                    text:
                        "If you're having issues with the app, consider contacting our support team first.",
                  ),
                  _DeleteAccountListItem(
                    number: 2,
                    text:
                        "Download any data you want to keep, as it will all be deleted.",
                  ),
                  _DeleteAccountListItem(
                    number: 3,
                    text:
                        "If you have an active subscription, it will be canceled immediately.",
                  ),
                  const SizedBox(height: 40),
                  _buildDeleteButton(context),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'This action cannot be undone.',
                      style: TextStyle(color: Colors.white54, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: const Color(0x22000000),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade900, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.warning, color: Colors.red, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Warning',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                SizedBox(height: 4),
                Text(
                  "Deleting your account is permanent. All your data will be wiped out immediately and you won't be able to get it back.",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: _isLoading
            ? null
            : () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text(
                        'Are you sure you want to delete your account? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  setState(() => _isLoading = true);
                  try {
                    final deleteService = getIt<
                        DeleteAccountService>(); // ✅ use registered service
                    await deleteService.deleteAccount();

                    await AuthManager.clearAuthToken();
                    await AuthManager.clearUserId();

                    GoRouter.of(context).go('/login'); // 🔁 Clear stack
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete account: $e')),
                    );
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                }
              },
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Delete My Account',
                style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}

class _DeleteAccountListItem extends StatelessWidget {
  final int number;
  final String text;
  const _DeleteAccountListItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF222325),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              number.toString(),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
