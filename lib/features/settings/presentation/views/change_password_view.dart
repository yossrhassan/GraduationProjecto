import 'package:flutter/material.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  bool get hasMinLength => newPasswordController.text.length >= 8;
  bool get hasNumber => RegExp(r'[0-9]').hasMatch(newPasswordController.text);
  bool get hasSpecial =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(newPasswordController.text);

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePassword() async {
    // TODO: Implement password update logic
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: const Text('Change Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: const Color(0xFF18191A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Your password must be at least 8 characters long and include a mix of letters, numbers, and special characters.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              const Text('New Password',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              const Text('Confirm New Password',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 32),
              _PasswordRequirementRow(
                met: hasMinLength,
                text: 'At least 8 characters',
              ),
              _PasswordRequirementRow(
                met: hasNumber,
                text: 'Contains a number',
              ),
              _PasswordRequirementRow(
                met: hasSpecial,
                text: 'Contains a special character',
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _updatePassword,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Update Password',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF18191A),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

class _PasswordRequirementRow extends StatelessWidget {
  final bool met;
  final String text;
  const _PasswordRequirementRow({required this.met, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.circle,
              size: 18, color: met ? Colors.green : Colors.white24),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: met ? Colors.green : Colors.white54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
