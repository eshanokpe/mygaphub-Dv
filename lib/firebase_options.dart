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
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBZAT95qOXukJ0UFvXUjfmj7zna39onvCE',
    appId: '1:1020147279728:android:60dee043e1bfef8c0d91b5',
    messagingSenderId: '1020147279728',
    projectId: 'mygaphub-b4910',
    storageBucket: 'mygaphub-b4910.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBZAT95qOXukJ0UFvXUjfmj7zna39onvCE',
    appId:
        '1:1020147279728:ios:YOUR_IOS_APP_ID', // You need to add iOS app in Firebase console
    messagingSenderId: '1020147279728',
    projectId: 'mygaphub-b4910',
    storageBucket: 'mygaphub-b4910.appspot.com',
    iosBundleId: 'com.prismcheck.gaphub', // Update with your actual bundle ID
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBZAT95qOXukJ0UFvXUjfmj7zna39onvCE',
    appId: '1:1020147279728:web:YOUR_WEB_APP_ID',
    messagingSenderId: '1020147279728',
    projectId: 'mygaphub-b4910',
    authDomain: 'mygaphub-b4910.firebaseapp.com',
    storageBucket: 'mygaphub-b4910.appspot.com',
    measurementId: 'G-MEASUREMENT_ID',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBZAT95qOXukJ0UFvXUjfmj7zna39onvCE',
    appId: '1:1020147279728:ios:YOUR_MACOS_APP_ID',
    messagingSenderId: '1020147279728',
    projectId: 'mygaphub-b4910',
    storageBucket: 'mygaphub-b4910.appspot.com',
  );
}
