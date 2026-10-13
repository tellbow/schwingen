// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Tellbow';

  @override
  String get tabWrestlers => 'Lutteurs';

  @override
  String get tabPlaces => 'Fêtes de lutte';

  @override
  String get tabHeadToHead => 'Comparaison';

  @override
  String get tabStatistics => 'Statistiques';

  @override
  String get searchWrestlers => 'Nom, prénom ou club';

  @override
  String get searchPlaces => 'Fête ou lieu';

  @override
  String get noResults => 'Aucun résultat trouvé';

  @override
  String get noData => 'Aucune donnée disponible.';

  @override
  String get all => 'Tous';

  @override
  String get year => 'Année';

  @override
  String get yearOfBirth => 'Année de naissance';

  @override
  String get club => 'Club';

  @override
  String eloOfYear(int year) {
    return 'ELO $year';
  }

  @override
  String get wins => 'Victoires';

  @override
  String get draws => 'Nuls';

  @override
  String get losses => 'Défaites';

  @override
  String get averageRank => 'Rang moy.';

  @override
  String get averagePoints => 'Points moy.';

  @override
  String get wreathCantonal => 'Couronnes cantonales';

  @override
  String get wreathRegional => 'Couronnes régionales et de montagne';

  @override
  String get wreathFederal => 'Couronnes fédérales';

  @override
  String get rankings => 'Classements';

  @override
  String get opponents => 'Adversaires les plus fréquents';

  @override
  String round(int round) {
    return 'Passe $round';
  }

  @override
  String get points => 'Points';

  @override
  String get wrestler1 => 'Lutteur 1';

  @override
  String get wrestler2 => 'Lutteur 2';

  @override
  String get pickWrestler => 'Choisir un lutteur';

  @override
  String get swap => 'Échanger';

  @override
  String get meetings => 'Rencontres';

  @override
  String get noMeetings => 'Ces deux lutteurs ne se sont jamais affrontés.';

  @override
  String get topElo => 'Top 5 – Classement ELO';

  @override
  String get topAvgRank => 'Top 5 – Rang moy.';

  @override
  String get topAvgPoints => 'Top 5 – Points moy.';

  @override
  String get topWins => 'Top 5 – le plus de victoires';

  @override
  String get topWreaths => 'Top 5 – le plus de couronnes';

  @override
  String get topPlaces => 'Top 5 – le plus de participations';

  @override
  String get fiveEvents => '5 participations par année ou plus';

  @override
  String withWreath(int count) {
    return '$count avec couronne';
  }

  @override
  String get drawRatio => '% de passes nulles';

  @override
  String get drawRatioCaption => 'Proportion de passes finales nulles';

  @override
  String get dataTitle => 'Charger les données';

  @override
  String dataText(int size) {
    return 'Tellbow enregistre tous les résultats sur l\'iPhone. Un seul téléchargement ($size Mo), ensuite l\'app fonctionne sans Internet.';
  }

  @override
  String get checking => 'Recherche des dernières données…';

  @override
  String get download => 'Charger';

  @override
  String downloading(int percent) {
    return 'Chargement des données… $percent %';
  }

  @override
  String get retry => 'Réessayer';

  @override
  String failed(String error) {
    return 'Erreur : $error';
  }

  @override
  String get noRelease => 'Aucune donnée trouvée.';

  @override
  String updateAvailable(String tag, int size) {
    return 'Nouvelles données disponibles ($tag, $size Mo)';
  }

  @override
  String get later => 'Plus tard';

  @override
  String dataVersion(String tag) {
    return 'Données $tag';
  }

  @override
  String get openProfile => 'Voir le profil';

  @override
  String winsWithRate(int percent) {
    return 'Victoires · $percent %';
  }

  @override
  String get tabAssociations => 'Associations';

  @override
  String get total => 'Total';

  @override
  String get active => 'Actifs';

  @override
  String activeCount(int count) {
    return '$count actifs';
  }

  @override
  String get cantons => 'Cantons / fédérations régionales';

  @override
  String get clubs => 'Clubs de lutte';

  @override
  String get navPlaces => 'Fêtes';

  @override
  String get navHeadToHead => 'Duel';
}
