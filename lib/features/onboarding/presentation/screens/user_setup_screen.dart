import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netsim_mobile/features/logs/logic/logs_provider.dart';

class UserSetupScreen extends ConsumerStatefulWidget {
  const UserSetupScreen({super.key});

  @override
  ConsumerState<UserSetupScreen> createState() => _UserSetupScreenState();
}

class _UserSetupScreenState extends ConsumerState<UserSetupScreen> {
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isAdmin = false;
  bool _isLoading = false;

  Future<void> _continue() async {
    final name = _nameController.text.trim();
    final pin = _pinController.text.trim();

    if (name.isEmpty) {
      ShadToaster.of(context).show(
        const ShadToast(description: Text('Please enter your name.')),
      );
      return;
    }

    if (_isAdmin && pin != '1234') {
      ShadToaster.of(context).show(
        const ShadToast(description: Text('Invalid admin PIN!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setBool('isAdmin', _isAdmin);

    // Immediately reload logs for the newly selected player so UI updates without restarting
    try {
      await ref.read(logsProvider.notifier).reloadForCurrentPlayer();
      await ref.read(latestLogsProvider.notifier).reloadForCurrentPlayer();
      await ref.read(latestLogProvider.notifier).reloadForCurrentPlayer();
    } catch (e) {
      debugPrint('Error reloading logs after user switch: $e');
    }

    // Verify the save worked
    final savedName = prefs.getString('userName');
    debugPrint(' User setup completed: name=$savedName, admin=$_isAdmin');

    setState(() => _isLoading = false);

    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ShadCard(
            
            title: SizedBox(
              height: 60,
              child: const Text(
                "Welcome to Network Simulation Game",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            
            child: Column(
              spacing: 30,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 👤 Name Field
                ShadInput(
                  controller: _nameController,
                  placeholder: const Text("Enter your name"),
                ),

                // 🧩 Admin Switch
                ShadSwitch(
                  label: const Text("Are you an Admin?"),
                  // description: const Text("Enable admin mode for scenario editing."),
                  value: _isAdmin,
                  onChanged: (val) => setState(() => _isAdmin = val),
                ),

                // 🔐 Admin PIN (if admin)
                if (_isAdmin)
                  ShadInput(
                    controller: _pinController,
                    placeholder: const Text("Enter Admin PIN"),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                  ),

                // 🚀 Continue Button
                ShadButton(
                  onPressed: _isLoading ? null : _continue,
                  width: double.infinity,
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 10),
                            Text("Please wait..."),
                          ],
                        )
                      : const Text("Continue"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
