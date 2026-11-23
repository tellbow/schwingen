import type PocketBase from 'pocketbase';
import type { EloRecord, RankingRecord, WithExpand } from '#lib/types/pocketbase.js';
import { yearOnly } from '#lib/utils/format.js';

export type ProfileYear = number | 'Alle';
export type ProfileRanking = WithExpand<RankingRecord, 'place'>;

export const PROFILE_YEARS: ProfileYear[] = [
	2015,
	2016,
	2017,
	2018,
	2019,
	2020,
	2021,
	2022,
	2023,
	2024,
	2025,
	2026,
	'Alle'
];

export async function fetchWrestlerRankings(
	pb: PocketBase,
	wrestlerId: string,
	year: ProfileYear
): Promise<ProfileRanking[]> {
	const filter =
		year === 'Alle'
			? `wrestler.id = "${wrestlerId}"`
			: `wrestler.id = "${wrestlerId}" && place.year ~ "${year}"`;
	const rankings = await pb.collection('rankings').getFullList<ProfileRanking>(200, {
		filter,
		expand: 'place,place.placeType',
		sort: '-place.year,-created',
		fields:
			'id,rank,rank2,points,final,result,wreath,status,expand.place.id,expand.place.name,expand.place.year,expand.place.expand.placeType.type'
	});
	for (const r of rankings) {
		if (r.expand?.place) {
			r.expand.place.originalDate = r.expand.place.year;
			r.expand.place.year = yearOnly(r.expand.place.year);
		}
	}
	return rankings;
}

async function fetchEloForYear(pb: PocketBase, wrestlerId: string, year: number) {
	try {
		const res = await pb.collection(`elo${year}`).getList<EloRecord>(1, 1, {
			filter: `wrestler.id="${wrestlerId}"`,
			skipTotal: true,
			fields: 'id,rating'
		});
		return res.items[0] ?? null;
	} catch {
		return null;
	}
}

export async function fetchWrestlerElo(
	pb: PocketBase,
	wrestlerId: string,
	year: ProfileYear
): Promise<{ rating: number | string }> {
	if (year !== 'Alle') return (await fetchEloForYear(pb, wrestlerId, year)) ?? { rating: '-' };
	const [mostRecent, ...rest] = PROFILE_YEARS.filter((y) => y !== 'Alle')
		.map(Number)
		.sort((a, b) => b - a);
	const recentHit = await fetchEloForYear(pb, wrestlerId, mostRecent);
	if (recentHit) return recentHit;
	const results = await Promise.all(rest.map((y) => fetchEloForYear(pb, wrestlerId, y)));
	return results.find((r) => r !== null) ?? { rating: '-' };
}

export function countWreaths(rankings: ProfileRanking[]): [number, number, number] {
	const counts: [number, number, number] = [0, 0, 0];
	for (const r of rankings) {
		if (!r.wreath) continue;
		const type = r.expand?.place?.expand?.placeType?.type;
		if (type === 'Gauverband' || type === 'Kantonal') counts[0]++;
		else if (type === 'Teilverband' || type === 'Berg') counts[1]++;
		else if (type === 'Eidgenössisch') counts[2]++;
	}
	return counts;
}
