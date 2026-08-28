import type { PageServerLoad } from './$types';
import { createServerPb } from '$lib/pb';

const CACHE_TTL_MS = 60 * 60 * 1000;
const cache = new Map<string, { data: any; cachedAt: number }>();

const VALID_YEARS = [
	'2015', '2016', '2017', '2018', '2019', '2021', '2022', '2023', '2024', '2025', '2026', 'Alle'
];

export const load: PageServerLoad = async ({ url }) => {
	const requestedYear = url.searchParams.get('year') || 'Alle';
	const year = VALID_YEARS.includes(requestedYear) ? requestedYear : 'Alle';

	const cached = cache.get(year);
	if (cached && Date.now() - cached.cachedAt < CACHE_TTL_MS) {
		return cached.data;
	}

	const pb = createServerPb();

	const loadYear = year === 'Alle' ? 'Overall' : year;
	const yearFormatFilter = year === 'Alle' ? '%' : year;

	try {
		const results: any = { year, eloData: [], averageRank: [], averagePoints: [], mostWins: [], mostWreaths: [], mostPlacesAttended: [], drawDecisionRatio: 0 };

		// Load data in parallel where possible
		const promises: Promise<void>[] = [];

		if (year !== 'Alle') {
			promises.push(
				pb.collection(`elo${loadYear}`).getList(1, 5, {
					expand: 'wrestler',
					sort: '-rating,-created',
					fields: 'id,rating,expand.wrestler.id,expand.wrestler.name,expand.wrestler.vorname',
					skipTotal: true
				}).then((d) => { results.eloData = d.items; }).catch(() => { results.eloData = []; })
			);
		}

		promises.push(
			pb.collection(`averageRank${loadYear}`).getList(1, 5, {
				fields: 'averageRank,wid,name,vorname,year',
				skipTotal: true
			}).then((d) => {
				results.averageRank = d.items.map((item: any) => ({
					...item,
					avgRank: Math.round(item.averageRank * 100) / 100
				}));
			}).catch(() => { results.averageRank = []; }),

			pb.collection(`averagePoints${loadYear}`).getList(1, 5, {
				fields: 'averagePoints,wid,name,vorname,year',
				skipTotal: true
			}).then((d) => {
				results.averagePoints = d.items.map((item: any) => ({
					...item,
					avgPoints: Math.round(item.averagePoints * 100) / 100
				}));
			}).catch(() => { results.averagePoints = []; }),

			pb.collection(`mostWins${loadYear}`).getList(1, 5, {
				sort: '-wins,-wreath',
				fields: 'wins,wreath,id,name,vorname',
				skipTotal: true
			}).then((d) => { results.mostWins = d.items; }).catch(() => { results.mostWins = []; }),

			pb.collection(`mostPlacesAttended${loadYear}`).getList(1, 5, {
				fields: 'placesAttended,id,name,vorname,year',
				skipTotal: true
			}).then((d) => { results.mostPlacesAttended = d.items; }).catch(() => { results.mostPlacesAttended = []; }),

			pb.collection(`mostWreaths${loadYear}`).getList(1, 5, {
				fields: 'wreath,id,name,vorname',
				skipTotal: true
			}).then((d) => { results.mostWreaths = d.items; }).catch(() => { results.mostWreaths = []; }),

			pb.collection('drawDecisionRatio').getList(1, 24, {
				filter: `yearFormat ~ '${yearFormatFilter}'`,
				fields: 'countDraw,countAll,yearFormat',
				skipTotal: true
			}).then((d) => {
				let sumAll = 0, sumDraw = 0;
				d.items.forEach((item: any) => {
					sumDraw += item.countDraw;
					sumAll += item.countAll;
				});
				results.drawDecisionRatio = sumAll > 0 ? Math.round((sumDraw / sumAll) * 100) : 0;
			}).catch(() => { results.drawDecisionRatio = 0; })
		);

		await Promise.all(promises);
		cache.set(year, { data: results, cachedAt: Date.now() });
		return results;
	} catch (e) {
		console.error('Error loading statistics:', e);
		return { year, eloData: [], averageRank: [], averagePoints: [], mostWins: [], mostWreaths: [], mostPlacesAttended: [], drawDecisionRatio: 0 };
	}
};
