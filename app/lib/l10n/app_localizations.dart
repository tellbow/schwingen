import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de'), Locale('fr')];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'Tellbow'**
  String get appTitle;

  /// No description provided for @tabWrestlers.
  ///
  /// In de, this message translates to:
  /// **'Schwinger'**
  String get tabWrestlers;

  /// No description provided for @tabPlaces.
  ///
  /// In de, this message translates to:
  /// **'Schwingfeste'**
  String get tabPlaces;

  /// No description provided for @tabHeadToHead.
  ///
  /// In de, this message translates to:
  /// **'Direktvergleich'**
  String get tabHeadToHead;

  /// No description provided for @tabStatistics.
  ///
  /// In de, this message translates to:
  /// **'Statistiken'**
  String get tabStatistics;

  /// No description provided for @searchWrestlers.
  ///
  /// In de, this message translates to:
  /// **'Name, Vorname oder Klub'**
  String get searchWrestlers;

  /// No description provided for @searchPlaces.
  ///
  /// In de, this message translates to:
  /// **'Schwingfest oder Ort'**
  String get searchPlaces;

  /// No description provided for @noResults.
  ///
  /// In de, this message translates to:
  /// **'Keine Einträge gefunden'**
  String get noResults;

  /// No description provided for @noData.
  ///
  /// In de, this message translates to:
  /// **'Keine Daten verfügbar.'**
  String get noData;

  /// No description provided for @all.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get all;

  /// No description provided for @year.
  ///
  /// In de, this message translates to:
  /// **'Jahr'**
  String get year;

  /// No description provided for @yearOfBirth.
  ///
  /// In de, this message translates to:
  /// **'Jahrgang'**
  String get yearOfBirth;

  /// No description provided for @club.
  ///
  /// In de, this message translates to:
  /// **'Klub'**
  String get club;

  /// No description provided for @eloOfYear.
  ///
  /// In de, this message translates to:
  /// **'ELO {year}'**
  String eloOfYear(int year);

  /// No description provided for @wins.
  ///
  /// In de, this message translates to:
  /// **'Siege'**
  String get wins;

  /// No description provided for @draws.
  ///
  /// In de, this message translates to:
  /// **'Gestellte'**
  String get draws;

  /// No description provided for @losses.
  ///
  /// In de, this message translates to:
  /// **'Niederlagen'**
  String get losses;

  /// No description provided for @averageRank.
  ///
  /// In de, this message translates to:
  /// **'Ø Rang'**
  String get averageRank;

  /// No description provided for @averagePoints.
  ///
  /// In de, this message translates to:
  /// **'Ø Punkte'**
  String get averagePoints;

  /// No description provided for @wreathCantonal.
  ///
  /// In de, this message translates to:
  /// **'Kantonale Kränze'**
  String get wreathCantonal;

  /// No description provided for @wreathRegional.
  ///
  /// In de, this message translates to:
  /// **'Teilverbands- und Bergkränze'**
  String get wreathRegional;

  /// No description provided for @wreathFederal.
  ///
  /// In de, this message translates to:
  /// **'Eidg. Kränze'**
  String get wreathFederal;

  /// No description provided for @rankings.
  ///
  /// In de, this message translates to:
  /// **'Ranglisten'**
  String get rankings;

  /// No description provided for @opponents.
  ///
  /// In de, this message translates to:
  /// **'Häufigste Gegner'**
  String get opponents;

  /// No description provided for @round.
  ///
  /// In de, this message translates to:
  /// **'{round}. Gang'**
  String round(int round);

  /// No description provided for @points.
  ///
  /// In de, this message translates to:
  /// **'Punkte'**
  String get points;

  /// No description provided for @wrestler1.
  ///
  /// In de, this message translates to:
  /// **'Schwinger 1'**
  String get wrestler1;

  /// No description provided for @wrestler2.
  ///
  /// In de, this message translates to:
  /// **'Schwinger 2'**
  String get wrestler2;

  /// No description provided for @pickWrestler.
  ///
  /// In de, this message translates to:
  /// **'Schwinger wählen'**
  String get pickWrestler;

  /// No description provided for @swap.
  ///
  /// In de, this message translates to:
  /// **'Tauschen'**
  String get swap;

  /// No description provided for @meetings.
  ///
  /// In de, this message translates to:
  /// **'Begegnungen'**
  String get meetings;

  /// No description provided for @noMeetings.
  ///
  /// In de, this message translates to:
  /// **'Die beiden haben noch nie gegeneinander geschwungen.'**
  String get noMeetings;

  /// No description provided for @topElo.
  ///
  /// In de, this message translates to:
  /// **'Top 5 – ELO-Rating'**
  String get topElo;

  /// No description provided for @topAvgRank.
  ///
  /// In de, this message translates to:
  /// **'Top 5 – Ø Rang'**
  String get topAvgRank;

  /// No description provided for @topAvgPoints.
  ///
  /// In de, this message translates to:
  /// **'Top 5 – Ø Punkte'**
  String get topAvgPoints;

  /// No description provided for @topWins.
  ///
  /// In de, this message translates to:
  /// **'Top 5 – meiste Siege'**
  String get topWins;

  /// No description provided for @topWreaths.
  ///
  /// In de, this message translates to:
  /// **'Top 5 – meiste Kränze'**
  String get topWreaths;

  /// No description provided for @topPlaces.
  ///
  /// In de, this message translates to:
  /// **'Top 5 – meiste Teilnahmen'**
  String get topPlaces;

  /// No description provided for @fiveEvents.
  ///
  /// In de, this message translates to:
  /// **'5 Teilnahmen pro Jahr oder mehr'**
  String get fiveEvents;

  /// No description provided for @withWreath.
  ///
  /// In de, this message translates to:
  /// **'{count} mit Kranz'**
  String withWreath(int count);

  /// No description provided for @drawRatio.
  ///
  /// In de, this message translates to:
  /// **'% Gestellte Gänge'**
  String get drawRatio;

  /// No description provided for @drawRatioCaption.
  ///
  /// In de, this message translates to:
  /// **'Anteil gestellter Gänge in Schlussgängen'**
  String get drawRatioCaption;

  /// No description provided for @dataTitle.
  ///
  /// In de, this message translates to:
  /// **'Daten laden'**
  String get dataTitle;

  /// No description provided for @dataText.
  ///
  /// In de, this message translates to:
  /// **'Tellbow speichert alle Resultate auf dem iPhone. Einmal laden ({size} MB), danach funktioniert die App ohne Internet.'**
  String dataText(int size);

  /// No description provided for @checking.
  ///
  /// In de, this message translates to:
  /// **'Neueste Daten werden gesucht…'**
  String get checking;

  /// No description provided for @download.
  ///
  /// In de, this message translates to:
  /// **'Laden'**
  String get download;

  /// No description provided for @downloading.
  ///
  /// In de, this message translates to:
  /// **'Daten werden geladen… {percent} %'**
  String downloading(int percent);

  /// No description provided for @retry.
  ///
  /// In de, this message translates to:
  /// **'Nochmals versuchen'**
  String get retry;

  /// No description provided for @failed.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {error}'**
  String failed(String error);

  /// No description provided for @noRelease.
  ///
  /// In de, this message translates to:
  /// **'Keine Daten gefunden.'**
  String get noRelease;

  /// No description provided for @updateAvailable.
  ///
  /// In de, this message translates to:
  /// **'Neue Daten verfügbar ({tag}, {size} MB)'**
  String updateAvailable(String tag, int size);

  /// No description provided for @later.
  ///
  /// In de, this message translates to:
  /// **'Später'**
  String get later;

  /// No description provided for @openProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil anzeigen'**
  String get openProfile;

  /// No description provided for @winsWithRate.
  ///
  /// In de, this message translates to:
  /// **'Siege · {percent} %'**
  String winsWithRate(int percent);

  /// No description provided for @tabAssociations.
  ///
  /// In de, this message translates to:
  /// **'Verbände'**
  String get tabAssociations;

  /// No description provided for @total.
  ///
  /// In de, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @active.
  ///
  /// In de, this message translates to:
  /// **'Aktive'**
  String get active;

  /// No description provided for @activeCount.
  ///
  /// In de, this message translates to:
  /// **'{count} Aktive'**
  String activeCount(int count);

  /// No description provided for @cantons.
  ///
  /// In de, this message translates to:
  /// **'Kantone / Gauverbände'**
  String get cantons;

  /// No description provided for @clubs.
  ///
  /// In de, this message translates to:
  /// **'Schwingklubs'**
  String get clubs;

  /// No description provided for @navPlaces.
  ///
  /// In de, this message translates to:
  /// **'Feste'**
  String get navPlaces;

  /// No description provided for @navHeadToHead.
  ///
  /// In de, this message translates to:
  /// **'Vergleich'**
  String get navHeadToHead;

  /// No description provided for @trends.
  ///
  /// In de, this message translates to:
  /// **'Verlauf'**
  String get trends;

  /// No description provided for @winRate.
  ///
  /// In de, this message translates to:
  /// **'Siegquote'**
  String get winRate;

  /// No description provided for @wreath.
  ///
  /// In de, this message translates to:
  /// **'Kranz'**
  String get wreath;

  /// No description provided for @settings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In de, this message translates to:
  /// **'Darstellung'**
  String get appearance;

  /// No description provided for @system.
  ///
  /// In de, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In de, this message translates to:
  /// **'Hell'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In de, this message translates to:
  /// **'Dunkel'**
  String get dark;

  /// No description provided for @language.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get language;

  /// No description provided for @data.
  ///
  /// In de, this message translates to:
  /// **'Daten'**
  String get data;

  /// No description provided for @installedData.
  ///
  /// In de, this message translates to:
  /// **'Installierte Daten'**
  String get installedData;

  /// No description provided for @dataInstalled.
  ///
  /// In de, this message translates to:
  /// **'{tag} · {size} MB'**
  String dataInstalled(String tag, int size);

  /// No description provided for @checkForData.
  ///
  /// In de, this message translates to:
  /// **'Nach neuen Daten suchen'**
  String get checkForData;

  /// No description provided for @upToDate.
  ///
  /// In de, this message translates to:
  /// **'Die Daten sind aktuell.'**
  String get upToDate;

  /// No description provided for @reloadData.
  ///
  /// In de, this message translates to:
  /// **'Daten löschen und neu laden'**
  String get reloadData;

  /// No description provided for @reloadDataText.
  ///
  /// In de, this message translates to:
  /// **'Die Daten werden vom iPhone gelöscht und gleich neu geladen. Dafür braucht es Internet.'**
  String get reloadDataText;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @reload.
  ///
  /// In de, this message translates to:
  /// **'Neu laden'**
  String get reload;

  /// No description provided for @about.
  ///
  /// In de, this message translates to:
  /// **'Über Tellbow'**
  String get about;

  /// No description provided for @version.
  ///
  /// In de, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @website.
  ///
  /// In de, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @dataSource.
  ///
  /// In de, this message translates to:
  /// **'Datenquelle'**
  String get dataSource;

  /// No description provided for @dataSourceText.
  ///
  /// In de, this message translates to:
  /// **'Ranglisten des Eidgenössischen Schwingerverbands (esv.ch)'**
  String get dataSourceText;

  /// No description provided for @licenses.
  ///
  /// In de, this message translates to:
  /// **'Open-Source-Lizenzen'**
  String get licenses;

  /// No description provided for @outcomesBySeason.
  ///
  /// In de, this message translates to:
  /// **'Siege, Gestellte und Niederlagen pro Saison'**
  String get outcomesBySeason;

  /// No description provided for @festivalRanks.
  ///
  /// In de, this message translates to:
  /// **'Rang pro Fest'**
  String get festivalRanks;

  /// No description provided for @festivalPoints.
  ///
  /// In de, this message translates to:
  /// **'Punkte pro Fest'**
  String get festivalPoints;

  /// No description provided for @rankAndPoints.
  ///
  /// In de, this message translates to:
  /// **'Rang {rank} · {points} Punkte'**
  String rankAndPoints(String rank, String points);

  /// No description provided for @rankBySeason.
  ///
  /// In de, this message translates to:
  /// **'Ø Rang pro Saison (Rang 1 oben)'**
  String get rankBySeason;

  /// No description provided for @pointsDistribution.
  ///
  /// In de, this message translates to:
  /// **'Punkteverteilung'**
  String get pointsDistribution;

  /// No description provided for @withWreathLegend.
  ///
  /// In de, this message translates to:
  /// **'mit Kranz'**
  String get withWreathLegend;

  /// No description provided for @withoutWreath.
  ///
  /// In de, this message translates to:
  /// **'ohne Kranz'**
  String get withoutWreath;

  /// No description provided for @activeByAssociation.
  ///
  /// In de, this message translates to:
  /// **'Aktive pro Verband'**
  String get activeByAssociation;

  /// No description provided for @activeByCanton.
  ///
  /// In de, this message translates to:
  /// **'Aktive pro Kanton / Gauverband'**
  String get activeByCanton;

  /// No description provided for @mapHint.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf eine Region für die Zahl.'**
  String get mapHint;

  /// No description provided for @bugReport.
  ///
  /// In de, this message translates to:
  /// **'Fehler melden'**
  String get bugReport;

  /// No description provided for @bugWhat.
  ///
  /// In de, this message translates to:
  /// **'Was ist passiert?'**
  String get bugWhat;

  /// No description provided for @bugPrivacy.
  ///
  /// In de, this message translates to:
  /// **'Der Bericht geht an das Tellbow-Team und ist nicht öffentlich: dein Text, wo du warst ({place}), die App-Version und iOS-Version.'**
  String bugPrivacy(String place);

  /// No description provided for @bugSend.
  ///
  /// In de, this message translates to:
  /// **'Senden'**
  String get bugSend;

  /// No description provided for @bugSent.
  ///
  /// In de, this message translates to:
  /// **'Danke! Dein Bericht ist angekommen.'**
  String get bugSent;

  /// No description provided for @bugFailed.
  ///
  /// In de, this message translates to:
  /// **'Das Senden hat nicht geklappt. Dein Text bleibt hier, versuch es gleich nochmals.'**
  String get bugFailed;

  /// No description provided for @bugBusy.
  ///
  /// In de, this message translates to:
  /// **'Gerade kamen zu viele Berichte von hier. Versuch es in einer Stunde nochmals.'**
  String get bugBusy;

  /// No description provided for @close.
  ///
  /// In de, this message translates to:
  /// **'Schliessen'**
  String get close;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
