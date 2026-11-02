import type { PageServerLoad } from './$types';
import { createServerPb } from '#lib/pb.js';
import { validateRouteParam } from '#lib/utils/filter.js';
import { groupBoutsByWrestler } from '#lib/utils/rankings.js';
import { yearOnly } from '#lib/utils/format.js';
import { error } from '@sveltejs/kit';
import type { BoutRecord, PlaceRecord, RankingRecord } from '#lib/types/pocketbase.js';

export const load: PageServerLoad = async ({ params }) => {
	let placeId: string;
	try {
		placeId = validateRouteParam(params.id);
	} catch {
		throw error(400, 'Invalid place ID');
	}

	const pb = createServerPb();

	let place: PlaceRecord;
	let rankingsResult: { items: RankingRecord[] };
	let bouts: BoutRecord[];
	try {
		[place, rankingsResult, bouts] = await Promise.all([
			pb.collection('places').getOne<PlaceRecord>(placeId, {
				expand: 'placeType',
				fields: 'id,name,location,year,number,expand.placeType.type'
			}),
			pb
				.collection('rankings')
				.getList<RankingRecord>(1, 500, {
					filter: `place = "${placeId}"`,
					expand: 'wrestler,wrestler.status',
					sort: '-created',
					fields:
						'id,rank,rank2,points,result,final,wreath,status,expand.wrestler.id,expand.wrestler.name,expand.wrestler.vorname,expand.wrestler.expand.status.symbol',
					skipTotal: true,
					requestKey: `rankings-place-${placeId}`
				})
				.catch((e) => {
					console.error('Error loading rankings:', placeId, e);
					return { items: [] };
				}),
			pb
				.collection('bouts')
				.getFullList<BoutRecord>(1000, {
					filter: `place = "${placeId}"`,
					expand: 'opponent,opponent.status',
					sort: 'wrestler.name,fight_round,-created',
					fields:
						'id,result,points,wrestler,expand.opponent.id,expand.opponent.name,expand.opponent.vorname,expand.opponent.expand.status.symbol',
					requestKey: `bouts-place-${placeId}`
				})
				.catch((e) => {
					console.error('Error loading bouts:', placeId, e);
					return [];
				})
		]);
	} catch (e) {
		console.error('Place not found:', placeId, e);
		throw error(404, 'Place not found');
	}

	place.year = yearOnly(place.year);

	const rankings = rankingsResult.items.sort((a, b) => {
		const na = parseInt(a.rank) || 0;
		const nb = parseInt(b.rank) || 0;
		if (na !== nb) return na - nb;
		return (a.rank2 || '').localeCompare(b.rank2 || '');
	});

	const boutsByWrestler = groupBoutsByWrestler(bouts);
	return {
		place,
		rankings: rankings.map((r) => ({
			...r,
			bouts: (r.expand?.wrestler && boutsByWrestler.get(r.expand.wrestler.id)) || []
		}))
	};
};
