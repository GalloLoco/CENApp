// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBL_JuAbsiYD-X95w7EyKgwWE6Ueid7HTo',
    appId: '1:655184602436:web:c73294812793278e1d2311',
    messagingSenderId: '655184602436',
    projectId: 'cenapp-63a56',
    authDomain: 'cenapp-63a56.firebaseapp.com',
    storageBucket: 'cenapp-63a56.firebasestorage.app',
    measurementId: 'G-GC1ENC0KPH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBf_20EEadMADwQXUfADLHmjAQ5VsXDQng',
    appId: '1:223900357323:android:242d8262becff918a2814e',
    messagingSenderId: '223900357323',
    projectId: 'geosismicaapp',
    storageBucket: 'geosismicaapp.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB7prRL1Tfpu-Hcrt7od_R9zoPSCu76RKI',
    appId: '1:223900357323:ios:7cfc0d11473beb0ca2814e',
    messagingSenderId: '223900357323',
    projectId: 'geosismicaapp',
    storageBucket: 'geosismicaapp.firebasestorage.app',
    iosBundleId: 'com.example.cenapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD8rGztb_0PxH1qIfIkPqJNG6ziikjJAiU',
    appId: '1:655184602436:ios:6d3f9ebc043af2501d2311',
    messagingSenderId: '655184602436',
    projectId: 'cenapp-63a56',
    storageBucket: 'cenapp-63a56.firebasestorage.app',
    iosBundleId: 'com.example.cenapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBL_JuAbsiYD-X95w7EyKgwWE6Ueid7HTo',
    appId: '1:655184602436:web:3f7b98bdbf7b6fd41d2311',
    messagingSenderId: '655184602436',
    projectId: 'cenapp-63a56',
    authDomain: 'cenapp-63a56.firebaseapp.com',
    storageBucket: 'cenapp-63a56.firebasestorage.app',
    measurementId: 'G-GJDV550H2E',
  );
}