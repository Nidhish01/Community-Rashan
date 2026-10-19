import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Firebase project: community-rashan (Spark / free plan).
///
/// These are the Web app's config values (safe to commit — Firebase web config
/// is public by design; security comes from Firestore rules + Auth). A native
/// Android build will later need its own registration (google-services.json +
/// SHA-1) — see ../../docs/FIREBASE_SETUP.md Part 3.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
        apiKey: 'AIzaSyALJFOQX9HEL_Myq2SBqiSj1ZS0_yb-N7A',
        appId: '1:18441421439:web:71841abce0e16dab67b54a',
        messagingSenderId: '18441421439',
        projectId: 'community-rashan',
        authDomain: 'community-rashan.firebaseapp.com',
        storageBucket: 'community-rashan.firebasestorage.app',
        measurementId: 'G-FGVDFC7R7C',
      );
}
