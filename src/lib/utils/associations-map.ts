export interface MapFeature {
	properties?: { name?: string };
	[key: string]: unknown;
}

export interface MergedMapFeature extends MapFeature {
	id?: string;
	wrestlerActive: number;
}

export interface AssociationStat {
	id: string;
	abbreviation: string;
	wrestlerActive: number;
}

export interface CantonStat {
	id: string;
	name: string;
	association: string;
	wrestlerActive: number;
}

const ASSOCIATION_CANTONS: Record<string, string[]> = {
	BKSV: ['Bern'],
	ISV: ['Luzern', 'Nidwalden', 'Obwalden', 'Schwyz', 'Tessin', 'Uri', 'Zug'],
	NOSV: [
		'Appenzell Ausserrhoden',
		'Appenzell Innerrhoden',
		'Glarus',
		'Graubünden',
		'Schaffhausen',
		'St. Gallen',
		'Thurgau',
		'Zürich'
	],
	NWSV: ['Aargau', 'Basel-Stadt', 'Baselland', 'Solothurn'],
	SWSV: ['Fribourgeoise', 'Genevoise', 'Jura', 'Neuchâteloise', 'Valaisanne', 'Vaudoise']
};

const BERN_SUB_REGIONS = ['Berner-Jura', 'Emmental', 'Mittelland', 'Oberaargau', 'Oberland', 'Seeland'];

const CANTON_NAME_ALIASES: Record<string, string[]> = {
	'Ob- und Nidwalden': ['Obwalden', 'Nidwalden'],
	Appenzell: ['Appenzell Ausserrhoden', 'Appenzell Innerrhoden']
};

function toFeatureMap(cantonFeatures: MapFeature[]): Record<string, MergedMapFeature> {
	const byName: Record<string, MergedMapFeature> = {};
	for (const feature of cantonFeatures) {
		const name = feature.properties?.name;
		if (name) byName[name] = { ...feature, wrestlerActive: 0 };
	}
	return byName;
}

export function buildAssociationFeatures(
	cantonFeatures: MapFeature[],
	associations: AssociationStat[]
): MergedMapFeature[] {
	const byName = toFeatureMap(cantonFeatures);

	for (const association of associations) {
		const names = ASSOCIATION_CANTONS[association.abbreviation] ?? [];
		for (const name of names) {
			if (!byName[name]) continue;
			byName[name].wrestlerActive = association.wrestlerActive;
			byName[name].id = association.id;
		}
	}

	return Object.values(byName);
}

export function buildCantonFeatures(
	cantonFeatures: MapFeature[],
	cantons: CantonStat[],
	associationId?: string
): MergedMapFeature[] {
	const byName = toFeatureMap(cantonFeatures);
	const filteredCantons = associationId
		? cantons.filter((canton) => canton.association === associationId)
		: cantons;

	for (const canton of filteredCantons) {
		if (BERN_SUB_REGIONS.includes(canton.name)) {
			if (byName.Bern) byName.Bern.wrestlerActive += canton.wrestlerActive;
			continue;
		}

		const aliases = CANTON_NAME_ALIASES[canton.name];
		if (aliases) {
			for (const alias of aliases) {
				if (!byName[alias]) continue;
				byName[alias].wrestlerActive += canton.wrestlerActive;
				byName[alias].id = canton.id;
			}
			continue;
		}

		if (!byName[canton.name]) continue;
		byName[canton.name].wrestlerActive += canton.wrestlerActive;
		byName[canton.name].id = canton.id;
	}

	return Object.values(byName);
}

export function buildGauverbandFeatures(
	cantonFeatures: MergedMapFeature[],
	gauverbandFeatures: MapFeature[],
	bksvCantons: CantonStat[]
): MergedMapFeature[] {
	const withoutBern = cantonFeatures.filter((feature) => feature.properties?.name !== 'Bern');
	const cantonByName = Object.fromEntries(bksvCantons.map((canton) => [canton.name, canton]));

	const gauverbandTiles: MergedMapFeature[] = gauverbandFeatures.map((feature) => {
		const name = feature.properties?.name;
		const canton = name ? cantonByName[name] : undefined;
		return {
			...feature,
			id: canton?.id,
			wrestlerActive: canton?.wrestlerActive ?? 0
		};
	});

	return [...withoutBern, ...gauverbandTiles];
}
