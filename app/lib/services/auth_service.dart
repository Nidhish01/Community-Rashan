import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

/// A signed-in person, independent of the auth backend.
class AppUser {
  final String uid;
  final String? name;
  final String? email;
  final String? photoUrl;
  const AppUser({required this.uid, this.name, this.email, this.photoUrl});
}

abstract class AuthService {
  Stream<AppUser?> authStateChanges();
  AppUser? get currentUser;
  Future<void> signInWithGoogle();
  Future<void> signOut();
}

/// Real backend: Google sign-in → Firebase Auth.
class FirebaseAuthService implements AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  AppUser? _map(fb.User? u) => u == null
      ? null
      : AppUser(uid: u.uid, name: u.displayName, email: u.email, photoUrl: u.photoURL);

  @override
  Stream<AppUser?> authStateChanges() => _auth.authStateChanges().map(_map);

  @override
  AppUser? get currentUser => _map(_auth.currentUser);

  @override
  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      // Web: Firebase's built-in Google popup — no separate client ID needed.
      await _auth.signInWithPopup(fb.GoogleAuthProvider());
      return;
    }
    // Mobile: native Google sign-in → Firebase credential.
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // user cancelled
    final googleAuth = await googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() async {
    if (!kIsWeb) await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}

/// Offline fallback used until Firebase is configured: a demo user is already
/// "signed in" so the app is never blocked.
class GuestAuthService implements AuthService {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _user = const AppUser(uid: 'guest', name: 'Demo Aunty', email: 'demo@rashan.app');

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _user;
    yield* _controller.stream;
  }

  @override
  AppUser? get currentUser => _user;

  @override
  Future<void> signInWithGoogle() async {
    _user = const AppUser(uid: 'guest', name: 'Demo Aunty', email: 'demo@rashan.app');
    _controller.add(_user);
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }
}
