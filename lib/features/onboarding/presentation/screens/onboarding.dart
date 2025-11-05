import 'package:flutter/material.dart';
import 'package:netsim_mobile/core/widgets/theme_toggle_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  bool _isAdmin = false;
  String _userName = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAdmin = prefs.getBool('isAdmin') ?? false;
      _userName = prefs.getString('userName') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [ThemeToggleButton()],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ShadCard(
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: Text("Welcome, ${_userName.isNotEmpty ? _userName : 'Player'}")),
            ),
           
            child: Column(
              spacing: 15,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShadButton(
                  width: double.infinity,
                  leading: const Icon(Icons.play_arrow),
                  child: const Text("Start Game"),
                  onPressed: () => Navigator.pushNamed(context, "/dashboard"),
                ),
                ShadButton(
                  width: double.infinity,
                  leading: const Icon(Icons.leaderboard),
                  child: const Text("Leaderboard"),
                  onPressed: () => Navigator.pushNamed(context, "/leaderboard"),
                ),
                // Only show this button if user is admin
                if (_isAdmin)
                  ShadButton(
                    width: double.infinity,
                    leading: const Icon(Icons.edit),
                    child: const Text("Edit Scenarios"),
                    onPressed: () => Navigator.pushNamed(context, "/scenario"),
                  ),
               
                ShadButton(
                  width: double.infinity,
                  leading: const Icon(Icons.exit_to_app),
                  child: const Text("Exit"),
                  onPressed: () async {
                  // Show confirmation dialog
                  final shouldExit = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Exit Game?'),
                      content: const Text(
                        'Are you sure you want to exit the simulation? '
                        
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, false), // Cancel
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(context, true), // Confirm
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text(
                            'Exit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (shouldExit == true) {
                    Navigator.pushNamed(context, '/'); // Exit the app
                  }
                },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
