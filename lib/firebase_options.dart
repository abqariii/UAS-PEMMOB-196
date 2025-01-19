import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' 
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCBfzO0vPYyrHMDVah7drgnt6I_blXgThs",
    authDomain: "uas-pemmob-aa-168-196.firebaseapp.com",
    projectId: "uas-pemmob-aa-168-196",
    storageBucket: "uas-pemmob-aa-168-196.firebasestorage.app",
    messagingSenderId: "1006766220870",
    appId: "1:1006766220870:web:57d2c5a4395e2fa678cc47"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCBfzO0vPYyrHMDVah7drgnt6I_blXgThs",
    appId: "1:1006766220870:android:57d2c5a4395e2fa678cc47",
    messagingSenderId: "1006766220870",
    projectId: "uas-pemmob-aa-168-196",
    storageBucket: "uas-pemmob-aa-168-196.firebasestorage.app"
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "YOUR_IOS_API_KEY",
    appId: "YOUR_IOS_APP_ID",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    projectId: "YOUR_PROJECT_ID",
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: "YOUR_WINDOWS_API_KEY",
    appId: "YOUR_WINDOWS_APP_ID",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    projectId: "YOUR_PROJECT_ID",
  );
}