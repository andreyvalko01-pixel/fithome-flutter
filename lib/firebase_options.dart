// Цей файл перезаписує команда `flutterfire configure` під конкретний Firebase-проєкт.
// Поки її не запускали — застосунок працює повністю локально, без синхронізації.

import 'package:firebase_core/firebase_core.dart';

const firebaseConfigured = false;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform =>
      throw UnsupportedError('Запустіть flutterfire configure');
}
