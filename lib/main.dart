import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/local_store.dart';
import 'providers.dart';
import 'screens/home_shell.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await LocalStore.open();

  final container = ProviderContainer(
    overrides: [storeProvider.overrideWithValue(store)],
  );
  // Firebase стартує у фоні — інтерфейс не чекає на мережу
  container.read(syncProvider).start();

  runApp(
    UncontrolledProviderScope(container: container, child: const FitHomeApp()),
  );
}

class FitHomeApp extends StatelessWidget {
  const FitHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitHome',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: const Locale('uk'),
      supportedLocales: const [Locale('uk'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const HomeShell(),
    );
  }
}
