import 'package:firebase_core/firebase_core.dart';
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
    apiKey: 'AIzaSyBFMdIQ8qn5HHi6h8wPckxCZfxUobr0YFM',
    appId: '1:691963444627:web:f760643a9ebdb50ffcbc66',
    messagingSenderId: '691963444627',
    projectId: 'firechat-e36aa',
    authDomain: 'firechat-e36aa.firebaseapp.com',
    storageBucket: 'firechat-e36aa.firebasestorage.app',
  );

  //only this is used as i am running on android emulator
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBL7x5Q8Pck_jKJJCduBaZEy8LAj_if6B0',
    appId: '1:691963444627:android:3e480091e6c93bb1fcbc66',
    messagingSenderId: '691963444627',
    projectId: 'firechat-e36aa',
    storageBucket: 'firechat-e36aa.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBpxeEiqLZXsH09PgOBcVgqvGXU7jyMWQc',
    appId: '1:691963444627:ios:8875126ce5a36edbfcbc66',
    messagingSenderId: '691963444627',
    projectId: 'firechat-e36aa',
    storageBucket: 'firechat-e36aa.firebasestorage.app',
    iosBundleId: 'com.example.firechat',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBpxeEiqLZXsH09PgOBcVgqvGXU7jyMWQc',
    appId: '1:691963444627:ios:8875126ce5a36edbfcbc66',
    messagingSenderId: '691963444627',
    projectId: 'firechat-e36aa',
    storageBucket: 'firechat-e36aa.firebasestorage.app',
    iosBundleId: 'com.example.firechat',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBFMdIQ8qn5HHi6h8wPckxCZfxUobr0YFM',
    appId: '1:691963444627:web:42e4660ea44c128efcbc66',
    messagingSenderId: '691963444627',
    projectId: 'firechat-e36aa',
    authDomain: 'firechat-e36aa.firebaseapp.com',
    storageBucket: 'firechat-e36aa.firebasestorage.app',
  );
}
