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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Bootstrap());
}

class _Boot {
  final AuthService auth;
  final bool online;
  const _Boot(this.auth, this.online);
}

/// Shows a branded splash immediately, initializes Firebase in the background
/// (with a timeout so it can never hang), then hands off to the app.
class Bootstrap extends StatefulWidget {
  const Bootstrap({super.key});

  @override
  State<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  late final Future<_Boot> _future = _boot();

  Future<_Boot> _boot() async {
    var online = _firebaseConfigured;
    AuthService auth;
    if (online) {
      try {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
            .timeout(const Duration(seconds: 8));
        auth = FirebaseAuthService();
      } catch (_) {
        online = false; // unreachable / bad config — run on sample data
        auth = GuestAuthService();
      }
    } else {
      auth = GuestAuthService();
    }
    return _Boot(auth, online);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Rashan',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: FutureBuilder<_Boot>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) return const _Splash();
          return AuthGate(auth: snap.data!.auth, online: snap.data!.online);
        },
      ),
    );
  }
}

/// Branded loading screen (so the first paint is never a blank spinner).
class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: CR.green,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🛒', style: TextStyle(fontSize: 56)),
            SizedBox(height: 12),
            Text('Community Rashan',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
            SizedBox(height: 20),
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows login until signed in, then loads the catalogue (Firestore when online,
/// else sample data) and runs the app. Never hangs: Firestore load is capped and
/// falls back to sample data on any error/timeout.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.auth, required this.online});

  final AuthService auth;
  final bool online;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<Repository>? _repoFuture;

  Future<Repository> _loadRepo() async {
    if (!widget.online) return MockRepository();
    try {
      return await FirestoreRepository.load().timeout(const Duration(seconds: 12));
    } catch (_) {
      // Firestore not created yet / unreachable — still show sample groceries.
      return MockRepository();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: widget.auth.authStateChanges(),
      builder: (context, snap) {
        final user = snap.data;
        if (user == null) {
          _repoFuture = null; // reset for the next sign-in
          return LoginScreen(auth: widget.auth);
        }
        _repoFuture ??= _loadRepo();
        return FutureBuilder<Repository>(
          future: _repoFuture,
          builder: (context, repoSnap) {
            if (repoSnap.connectionState != ConnectionState.done) {
              return const _Splash();
            }
            final repo = repoSnap.data ?? MockRepository();
            return MultiProvider(
              providers: [
                Provider<AuthService>.value(value: widget.auth),
                ChangeNotifierProvider<AppState>(create: (_) => AppState(repo)),
              ],
              child: const RootScaffold(),
            );
          },
        );
      },
    );
  }
}
