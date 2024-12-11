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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyApLS4OairEfgL2-s1LU6Ccj9Ow38IX46I',
    appId: '1:402660503654:web:94f1caa9ea037f49257da7',
    messagingSenderId: '402660503654',
    projectId: 'projectuas-15a8e',
    authDomain: 'projectuas-15a8e.firebaseapp.com',
    storageBucket: 'projectuas-15a8e.firebasestorage.app',
    measurementId: 'G-JCHYZT10BV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCu4xU51axi1TXGZDhxQFtX7Rc2npS3kxE',
    appId: '1:402660503654:android:3b36a93fe649a1ac257da7',
    messagingSenderId: '402660503654',
    projectId: 'projectuas-15a8e',
    storageBucket: 'projectuas-15a8e.firebasestorage.app',
  );
}