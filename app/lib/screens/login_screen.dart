import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.auth});
  final AuthService auth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CR.green,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🛒', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 14),
                const Text('Community Rashan',
                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text('मिलकर खरीदें, सस्ता पाएं',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 44),
                FilledButton.icon(
                  onPressed: () async {
                    try {
                      await auth.signInWithGoogle();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Login नहीं हुआ: $e')));
                      }
                    }
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Google से लॉगिन करें', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: CR.green,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('सुरक्षित लॉगिन · आपकी जानकारी किसी और को नहीं दिखेगी',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 12.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
