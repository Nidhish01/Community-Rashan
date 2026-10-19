import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/firestore_repository.dart';
import 'data/repository.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/root_scaffold.dart';
import 'services/auth_service.dart';
import 'state/app_state.dart';
import 'theme.dart';

/// Firebase is "configured" once flutterfire has filled in real values.
bool get _firebaseConfigured =>
    !DefaultFirebaseOptions.currentPlatform.apiKey.contains('REPLACE');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var online = _firebaseConfigured;
  AuthService auth;
  if (online) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
          .timeout(const Duration(seconds: 8));
      auth = FirebaseAuthService();
    } catch (_) {
      // Unreachable network or bad config — don't hang; run on sample data.
      online = false;
      auth = GuestAuthService();
    }
  } else {
    auth = GuestAuthService();
  }

  runApp(CommunityRashanApp(auth: auth, online: online));
}

class CommunityRashanApp extends StatelessWidget {
  const CommunityRashanApp({super.key, required this.auth, required this.online});

  final AuthService auth;
  final bool online;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Rashan',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: AuthGate(auth: auth, online: online),
    );
  }
}

/// Shows the login screen until signed in, then loads the catalogue (from
/// Firestore when online, else sample data) and runs the app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.auth, required this.online});

  final AuthService auth;
  final bool online;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: auth.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _Loading();
        }
        if (snap.data == null) {
          return LoginScreen(auth: auth);
        }
        return FutureBuilder<Repository>(
          future: online ? FirestoreRepository.load() : Future<Repository>.value(MockRepository()),
          builder: (context, repoSnap) {
            if (!repoSnap.hasData) return const _Loading();
            return MultiProvider(
              providers: [
                Provider<AuthService>.value(value: auth),
                ChangeNotifierProvider<AppState>(create: (_) => AppState(repoSnap.data!)),
              ],
              child: const RootScaffold(),
            );
          },
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
