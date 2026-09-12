import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AlzaSyCT-hJU-vD81Q5pxc2pn0sWvlQriSW_caQ',
    appId: '1:507830436078:android:4604dad4cb0d016fb333ff',
    messagingSenderId: '507830436078',
    projectId: 'autocare-2f41c',
    storageBucket: 'autocare-2f41c.firebasestorage.app',
  );
}
