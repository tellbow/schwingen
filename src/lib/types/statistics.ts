import type { EloRecord } from './pocketbase';

export interface WrestlerStatBase {
	name: string;
	vorname: string;
	year?: string;
}

export interface AverageRankEntry extends WrestlerStatBase {
	wid: string;
	averageRank: number;
	avgRank: number;
}

export interface AveragePointsEntry extends WrestlerStatBase {
	wid: string;
	averagePoints: number;
	avgPoints: number;
}

export interface MostWinsEntry extends WrestlerStatBase {
	id: string;
	wins: number;
	wreath: number;
}

export interface MostWreathsEntry extends WrestlerStatBase {
	id: string;
	wreath: number;
}

export interface MostPlacesAttendedEntry extends WrestlerStatBase {
	id: string;
	placesAttended: number;
}

export interface DrawDecisionRatioRecord {
	countDraw: number;
	countAll: number;
	yearFormat: string;
}

export interface StatisticsData {
	year: string;
	eloData: EloRecord[];
	averageRank: AverageRankEntry[];
	averagePoints: AveragePointsEntry[];
	mostWins: MostWinsEntry[];
	mostWreaths: MostWreathsEntry[];
	mostPlacesAttended: MostPlacesAttendedEntry[];
	drawDecisionRatio: number;
}
