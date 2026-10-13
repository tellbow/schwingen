// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Tellbow';

  @override
  String get tabWrestlers => 'Schwinger';

  @override
  String get tabPlaces => 'Schwingfeste';

  @override
  String get tabHeadToHead => 'Direktvergleich';

  @override
  String get tabStatistics => 'Statistiken';

  @override
  String get searchWrestlers => 'Name, Vorname oder Klub';

  @override
  String get searchPlaces => 'Schwingfest oder Ort';

  @override
  String get noResults => 'Keine Einträge gefunden';

  @override
  String get noData => 'Keine Daten verfügbar.';

  @override
  String get all => 'Alle';

  @override
  String get year => 'Jahr';

  @override
  String get yearOfBirth => 'Jahrgang';

  @override
  String get club => 'Klub';

  @override
  String eloOfYear(int year) {
    return 'ELO $year';
  }

  @override
  String get wins => 'Siege';

  @override
  String get draws => 'Gestellte';

  @override
  String get losses => 'Niederlagen';

  @override
  String get averageRank => 'Ø Rang';

  @override
  String get averagePoints => 'Ø Punkte';

  @override
  String get wreathCantonal => 'Kantonale Kränze';

  @override
  String get wreathRegional => 'Teilverbands- und Bergkränze';

  @override
  String get wreathFederal => 'Eidg. Kränze';

  @override
  String get rankings => 'Ranglisten';

  @override
  String get opponents => 'Häufigste Gegner';

  @override
  String round(int round) {
    return '$round. Gang';
  }

  @override
  String get points => 'Punkte';

  @override
  String get wrestler1 => 'Schwinger 1';

  @override
  String get wrestler2 => 'Schwinger 2';

  @override
  String get pickWrestler => 'Schwinger wählen';

  @override
  String get swap => 'Tauschen';

  @override
  String get meetings => 'Begegnungen';

  @override
  String get noMeetings => 'Die beiden haben noch nie gegeneinander geschwungen.';

  @override
  String get topElo => 'Top 5 – ELO-Rating';

  @override
  String get topAvgRank => 'Top 5 – Ø Rang';

  @override
  String get topAvgPoints => 'Top 5 – Ø Punkte';

  @override
  String get topWins => 'Top 5 – meiste Siege';

  @override
  String get topWreaths => 'Top 5 – meiste Kränze';

  @override
  String get topPlaces => 'Top 5 – meiste Teilnahmen';

  @override
  String get fiveEvents => '5 Teilnahmen pro Jahr oder mehr';

  @override
  String withWreath(int count) {
    return '$count mit Kranz';
  }

  @override
  String get drawRatio => '% Gestellte Gänge';

  @override
  String get drawRatioCaption => 'Anteil gestellter Gänge in Schlussgängen';

  @override
  String get dataTitle => 'Daten laden';

  @override
  String dataText(int size) {
    return 'Tellbow speichert alle Resultate auf dem iPhone. Einmal laden ($size MB), danach funktioniert die App ohne Internet.';
  }

  @override
  String get checking => 'Neueste Daten werden gesucht…';

  @override
  String get download => 'Laden';

  @override
  String downloading(int percent) {
    return 'Daten werden geladen… $percent %';
  }

  @override
  String get retry => 'Nochmals versuchen';

  @override
  String failed(String error) {
    return 'Fehler: $error';
  }

  @override
  String get noRelease => 'Keine Daten gefunden.';

  @override
  String updateAvailable(String tag, int size) {
    return 'Neue Daten verfügbar ($tag, $size MB)';
  }

  @override
  String get later => 'Später';

  @override
  String dataVersion(String tag) {
    return 'Daten $tag';
  }

  @override
  String get openProfile => 'Profil anzeigen';

  @override
  String winsWithRate(int percent) {
    return 'Siege · $percent %';
  }

  @override
  String get tabAssociations => 'Verbände';

  @override
  String get total => 'Total';

  @override
  String get active => 'Aktive';

  @override
  String activeCount(int count) {
    return '$count Aktive';
  }

  @override
  String get cantons => 'Kantone / Gauverbände';

  @override
  String get clubs => 'Schwingklubs';

  @override
  String get navPlaces => 'Feste';

  @override
  String get navHeadToHead => 'Vergleich';
}
