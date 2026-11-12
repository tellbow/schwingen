export const privacyDe = {
	title: 'Datenschutz',
	metaDescription:
		'Welche Daten Tellbow auf der Website und in der App «Schwingen» bearbeitet, und welche nicht.',
	updated: 'Stand: November 2026',
	intro:
		'Tellbow zeigt öffentliche Daten zum Schwingen. Es gibt keine Konten, keine Werbung, keine Cookies und kein Tracking. Diese Erklärung gilt für die Website schwingen.tellbow.ch und die iOS-App «Schwingen».',
	controllerTitle: 'Verantwortlich',
	controller: 'Adrian Berger, Schweiz. Kontakt: support@tellbow.ch',
	websiteTitle: 'Website',
	website:
		'Die Website läuft auf eigenen Servern in der Schweiz. Beim Aufruf einer Seite verarbeitet der Server technisch nötige Angaben (IP-Adresse, aufgerufene Seite, Zeitpunkt, Browser), um sie auszuliefern und den Betrieb zu überwachen. Sie werden nicht mit anderen Daten verknüpft und nur so lange aufbewahrt, wie es für Betrieb und Fehlersuche nötig ist. Ob du den dunklen Modus gewählt hast, speichert nur dein Browser.',
	fontsTitle: 'Schriften von Google',
	fonts:
		'Die Website lädt ihre Schriften von Google Fonts (Google LLC, USA). Dabei erhält Google deine IP-Adresse.',
	appTitle: 'App «Schwingen»',
	app: 'Die App braucht kein Konto. Sie lädt die Daten von den öffentlichen Releases auf GitHub (GitHub Inc., USA) herunter und prüft dort regelmässig, ob es neue gibt; dabei erhält GitHub deine IP-Adresse. Deine Einstellungen bleiben auf dem Gerät.',
	bugReportTitle: '«Fehler melden»',
	bugReport:
		'Wenn du einen Fehler meldest, gehen dein Text, die Seite oder Ansicht, die Version, Browser bzw. Betriebssystem und, wenn du es anhakst, ein Bildschirmfoto an Tellbow. Der Bericht wird in einem nicht öffentlichen Repository auf GitHub (GitHub Inc., USA) gespeichert, bis er erledigt ist. Deine IP-Adresse wird nur kurz im Arbeitsspeicher gehalten, um zu viele Berichte von derselben Stelle abzuwehren, und nicht gespeichert.',
	abroadTitle: 'Bekanntgabe ins Ausland',
	abroad:
		'Google und GitHub bearbeiten Daten in den USA. Beide sind unter dem Swiss-U.S. Data Privacy Framework zertifiziert.',
	rightsTitle: 'Deine Rechte',
	rights:
		'Du kannst Auskunft über deine Daten verlangen und sie berichtigen oder löschen lassen: support@tellbow.ch. Beschwerden kannst du beim Eidgenössischen Datenschutz- und Öffentlichkeitsbeauftragten (EDÖB) einreichen.'
};

export const privacyFr: typeof privacyDe = {
	title: 'Protection des données',
	metaDescription:
		'Quelles données Tellbow traite sur le site web et dans l’app « Lutte suisse », et lesquelles non.',
	updated: 'État : novembre 2026',
	intro:
		'Tellbow présente des données publiques sur la lutte suisse. Il n’y a ni compte, ni publicité, ni cookies, ni suivi. Cette déclaration s’applique au site schwingen.tellbow.ch et à l’app iOS « Lutte suisse ».',
	controllerTitle: 'Responsable',
	controller: 'Adrian Berger, Suisse. Contact : support@tellbow.ch',
	websiteTitle: 'Site web',
	website:
		'Le site fonctionne sur nos propres serveurs en Suisse. Lorsqu’une page est consultée, le serveur traite les informations techniquement nécessaires (adresse IP, page consultée, heure, navigateur) pour la fournir et surveiller le fonctionnement. Elles ne sont pas reliées à d’autres données et ne sont conservées que le temps nécessaire à l’exploitation et à la recherche d’erreurs. Le choix du mode sombre n’est enregistré que dans ton navigateur.',
	fontsTitle: 'Polices de Google',
	fonts:
		'Le site charge ses polices depuis Google Fonts (Google LLC, États-Unis). Google reçoit ainsi ton adresse IP.',
	appTitle: 'App « Lutte suisse »',
	app: 'L’app ne nécessite aucun compte. Elle télécharge les données depuis les releases publiques sur GitHub (GitHub Inc., États-Unis) et y vérifie régulièrement s’il en existe de nouvelles ; GitHub reçoit ainsi ton adresse IP. Tes réglages restent sur l’appareil.',
	bugReportTitle: '« Signaler un problème »',
	bugReport:
		'Lorsque tu signales un problème, ton texte, la page ou la vue, la version, le navigateur ou le système d’exploitation et, si tu le coches, une capture d’écran sont envoyés à Tellbow. Le rapport est conservé dans un dépôt non public sur GitHub (GitHub Inc., États-Unis) jusqu’à ce qu’il soit traité. Ton adresse IP n’est gardée que brièvement en mémoire, pour bloquer un trop grand nombre de rapports depuis le même endroit, et n’est pas enregistrée.',
	abroadTitle: 'Communication à l’étranger',
	abroad:
		'Google et GitHub traitent des données aux États-Unis. Tous deux sont certifiés selon le Swiss-U.S. Data Privacy Framework.',
	rightsTitle: 'Tes droits',
	rights:
		'Tu peux demander des renseignements sur tes données et les faire rectifier ou effacer : support@tellbow.ch. Tu peux adresser une plainte au Préposé fédéral à la protection des données et à la transparence (PFPDT).'
};

export const PRIVACY_SECTIONS = [
	'controller',
	'website',
	'fonts',
	'app',
	'bugReport',
	'abroad',
	'rights'
] as const;
