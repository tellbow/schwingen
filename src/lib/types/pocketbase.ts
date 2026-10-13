export interface StatusRecord {
	status?: string;
	symbol?: string;
}

export interface AssociationRecord {
	abbreviation: string;
}

export interface CantonRecord {
	name: string;
	expand?: { association?: AssociationRecord };
}

export interface ClubRecord {
	id: string;
	name: string;
	expand?: { canton?: CantonRecord };
}

export interface WrestlerRecord {
	id: string;
	name: string;
	vorname: string;
	year?: string;
	category?: string;
	updated?: string;
	expand?: {
		status?: StatusRecord;
		club?: ClubRecord;
		metadata?: { website?: string };
	};
}

export interface PlaceTypeRecord {
	type: string;
}

export interface PlaceRecord {
	id: string;
	name: string;
	year: string;
	originalDate?: string;
	location?: string;
	number?: string;
	updated?: string;
	expand?: { placeType?: PlaceTypeRecord };
}

export interface RankingRecord {
	id: string;
	rank: string;
	rank2?: string;
	points: string;
	final?: boolean;
	result: string;
	wreath?: boolean;
	status?: string;
	expand?: { wrestler?: WrestlerRecord; place?: PlaceRecord };
}

export interface BoutRecord {
	id: string;
	result: string;
	points: string;
	fight_round?: string;
	wrestler: string;
	expand?: { wrestler?: WrestlerRecord; opponent?: WrestlerRecord; place?: PlaceRecord };
}

export interface EloRecord {
	id: string;
	rating: number;
	expand?: { wrestler?: WrestlerRecord };
}

export interface GroupStatsRecord {
	id: string;
	name: string;
	wrestlerAmount: number;
	wrestlerActive: number;
	wrestler1Star: number;
	wrestler2Star: number;
	wrestler3Star: number;
}

export interface AssociationStatsRecord extends GroupStatsRecord {
	abbreviation: string;
}

export interface CantonStatsRecord extends GroupStatsRecord {
	association: string;
}

export interface ClubStatsRecord extends GroupStatsRecord {
	canton: string;
}

export type WithExpand<
	T extends { expand?: object },
	K extends keyof NonNullable<T['expand']>
> = T & { expand: Required<Pick<NonNullable<T['expand']>, K>> };

export type RankingWithBouts = RankingRecord & { bouts: BoutRecord[] };
