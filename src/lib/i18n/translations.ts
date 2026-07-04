export type Locale = "de" | "fr";

export type Translations = Record<string, Record<string, string>>;

const de: Translations = {
	nav: {
		wrestler: "Schwinger",
		places: "Schwingfeste",
		rankings: "Ranglisten",
		bouts: "Paarungen",
		statistics: "Statistiken",
		head2head: "Direktvergleich",
		associations: "Verbände",
	},
	common: {
		loading: "Laden...",
		back: "← Zurück",
		noResults: "Keine Einträge gefunden",
		search: "Suchen...",
		page: "Seite",
		of: "von",
		filter: "Filtern",
	},
	wrestler: {
		title: "Schwinger",
		name: "Name",
		firstName: "Vorname",
		yearOfBirth: "Jahrgang",
		club: "Klub",
		status: "Status",
	},
	places: {
		title: "Schwingfeste",
		name: "Name",
		type: "Typ",
		location: "Ort",
	},
	rankings: {
		title: "Ranglisten",
		rank: "Rang",
		points: "Punkte",
		wreath: "Kranz",
		result: "Resultat",
		resultsTitle: "Resultate",
		tabRangliste: "Rangliste",
		tabStatistik: "Statistik",
	},
	bouts: {
		title: "Paarungen",
		round: "Gang",
		result: "Resultat",
		points: "Punkte",
		opponent: "Gegner",
	},
	statistics: {
		title: "Statistiken",
	},
	head2head: {
		title: "Direktvergleich",
		wins: "Siege",
		losses: "Niederlagen",
		draws: "Gestellte",
		total: "Total",
	},
	associations: {
		title: "Verbände",
	},
	home: {
		wrestlerDesc: "Enthält alle aktiven Schwinger aus der Datenbank des ESV (Stand 27.07.2025).",
		placesDesc: "Enthält alle Schwingfeste der Aktiven aus den Jahren 2015–2025.",
		statisticsDesc: "Statistiken über Schwinger: ELO-Ratings, Durchschnittsrang, Siege, Kränze und mehr.",
		head2headDesc: "Vergleichen Sie zwei Schwinger direkt miteinander. Statistiken und gemeinsame Kämpfe.",
		rankingsDesc: "Alle Ranglisten und Ergebnisse von Schweizer Schwingfesten (2015–2025).",
		associationsDesc: "Übersicht über Teilverbände, Kantone und Vereine im Schweizer Schwingen.",
		show: "Anzeigen",
	},
};

const fr: Translations = {
	nav: {
		wrestler: "Lutteurs",
		places: "Fêtes de lutte",
		rankings: "Classements",
		bouts: "Appariements",
		statistics: "Statistiques",
		head2head: "Comparaison directe",
		associations: "Associations",
	},
	common: {
		loading: "Chargement...",
		back: "← Retour",
		noResults: "Aucun résultat trouvé",
		search: "Rechercher...",
		page: "Page",
		of: "sur",
		filter: "Filtrer",
	},
	wrestler: {
		title: "Lutteurs",
		name: "Nom",
		firstName: "Prénom",
		yearOfBirth: "Année de naissance",
		club: "Club",
		status: "Statut",
	},
	places: {
		title: "Fêtes de lutte",
		name: "Nom",
		type: "Type",
		location: "Lieu",
	},
	rankings: {
		title: "Classements",
		rank: "Rang",
		points: "Points",
		wreath: "Couronne",
		result: "Résultat",
		resultsTitle: "Résultats",
		tabRangliste: "Classement",
		tabStatistik: "Statistiques",
	},
	bouts: {
		title: "Appariements",
		round: "Tour",
		result: "Résultat",
		points: "Points",
		opponent: "Adversaire",
	},
	statistics: {
		title: "Statistiques",
	},
	head2head: {
		title: "Comparaison directe",
		wins: "Victoires",
		losses: "Défaites",
		draws: "Nuls",
		total: "Total",
	},
	associations: {
		title: "Associations",
	},
	home: {
		wrestlerDesc: "Contient tous les lutteurs actifs de la base de données de l'ESV (état au 27.07.2025).",
		placesDesc: "Contient toutes les fêtes de lutte des actifs de 2015 à 2025.",
		statisticsDesc: "Statistiques sur les lutteurs: classements ELO, rang moyen, victoires, couronnes et plus.",
		head2headDesc: "Comparez deux lutteurs directement. Statistiques et combats communs.",
		rankingsDesc: "Tous les classements et résultats des fêtes de lutte suisses (2015–2025).",
		associationsDesc: "Aperçu des sous-fédérations, cantons et clubs dans la lutte suisse.",
		show: "Afficher",
	},
};

export const translations: Record<Locale, Translations> = { de, fr };
