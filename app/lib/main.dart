import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'data/store.dart';
import 'screens/data_gate.dart';
import 'settings.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await Settings.load();
  runApp(TellbowApp(store: openStore(), settings: settings));
}

class TellbowApp extends StatelessWidget {
  const TellbowApp({super.key, required this.store, required this.settings});

  final Future<DataStore> store;
  final Settings settings;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: settings,
    builder: (context, _) => MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: tellbowTheme(Brightness.light),
      darkTheme: tellbowTheme(Brightness.dark),
      themeMode: settings.themeMode,
      locale: settings.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: DataGate(store: store, settings: settings),
    ),
  );
}
