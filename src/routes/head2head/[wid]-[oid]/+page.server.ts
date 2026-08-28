import type { PageServerLoad } from './$types';
import { createServerPb } from '$lib/pb';
import { validateRouteParam } from '$lib/utils/filter';
import { yearOnly } from '$lib/utils/format';
import { error } from '@sveltejs/kit';

export const load: PageServerLoad = async ({ params }) => {
	let wid: string, oid: string;
	try {
		wid = validateRouteParam(params.wid);
		oid = validateRouteParam(params.oid);
	} catch {
		throw error(400, 'Invalid wrestler IDs');
	}

	const pb = createServerPb();

	try {
		// requestKey prevents auto-cancellation between parallel calls to the same collection
		const [wrestler, opponent, rankingsW, rankingsO, commonBouts] = await Promise.all([
			pb.collection('wrestler').getOne(wid, {
				fields: 'id,name,vorname',
				requestKey: `wrestler-${wid}`
			}),
			pb.collection('wrestler').getOne(oid, {
				fields: 'id,name,vorname',
				requestKey: `wrestler-${oid}`
			}),
			pb.collection('rankings').getFullList(500, {
				filter: `wrestler.id = "${wid}"`,
				expand: 'place',
				sort: '-place.year',
				fields: 'id,rank,points,final,wreath,status,expand.place.id,expand.place.name,expand.place.year',
				requestKey: `rankings-${wid}`
			}),
			pb.collection('rankings').getFullList(500, {
				filter: `wrestler.id = "${oid}"`,
				expand: 'place',
				sort: '-place.year',
				fields: 'id,rank,points,final,wreath,status,expand.place.id,expand.place.name,expand.place.year',
				requestKey: `rankings-${oid}`
			}),
			pb.collection('bouts').getFullList(100, {
				filter: `wrestler.id = "${wid}" && opponent.id = "${oid}"`,
				expand: 'place',
				sort: '-place.year',
				fields: 'id,result,points,expand.place.id,expand.place.name,expand.place.year',
				requestKey: `bouts-${wid}-${oid}`
			})
		]);

		commonBouts.forEach((b: any) => {
			b.expand.place.year = yearOnly(b.expand.place.year);
		});

		// Process rankings
		const processRankings = (data: any[]) => {
			return data.map((r: any) => ({
				...r,
				year: yearOnly(r.expand?.place?.year)
			}));
		};

		return {
			wrestler,
			opponent,
			rankingsW: processRankings(rankingsW),
			rankingsO: processRankings(rankingsO),
			commonBouts
		};
	} catch (e: any) {
		console.error(e);
		if (e?.status === 404) {
			throw error(404, 'Wrestlers not found');
		}
		throw error(500, 'Failed to load head-to-head data');
	}
};
