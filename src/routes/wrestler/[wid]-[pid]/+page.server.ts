import type { PageServerLoad } from './$types';
import { createServerPb } from '$lib/pb';
import { validateRouteParam } from '$lib/utils/filter';
import { error } from '@sveltejs/kit';

export const load: PageServerLoad = async ({ params }) => {
	let wid: string, pid: string;
	try {
		wid = validateRouteParam(params.wid);
		pid = validateRouteParam(params.pid);
	} catch {
		throw error(400, 'Invalid route parameters');
	}

	const pb = createServerPb();

	try {
		const [wrestler, place] = await Promise.all([
			pb.collection('wrestler').getOne(wid, {
				fields: 'id,name,vorname',
				requestKey: `wrestler-${wid}`
			}),
			pb.collection('places').getOne(pid, {
				expand: 'placeType',
				fields: 'id,name,location,year,expand.placeType.type',
				requestKey: `place-${pid}`
			})
		]);

		place.year = place.year ? place.year.split('-')[0] : place.year;

		let ranking: any = null;
		try {
			ranking = await pb.collection('rankings').getFirstListItem(
				`wrestler.id = "${wid}" && place.id = "${pid}"`,
				{ fields: 'id,rank,rank2,points,result,final,wreath,status' }
			);
		} catch {
			ranking = null;
		}

		const bouts = await pb.collection('bouts').getFullList(50, {
			filter: `wrestler.id = "${wid}" && place.id = "${pid}"`,
			expand: 'opponent',
			sort: 'fight_round,-created',
			fields:
				'id,fight_round,result,points,expand.opponent.id,expand.opponent.name,expand.opponent.vorname'
		});

		return { wrestler, place, ranking, bouts };
	} catch (e) {
		console.error(e);
		throw error(404, 'Wrestler or place not found');
	}
};
