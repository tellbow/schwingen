import type { PageServerLoad } from './$types';
import { createServerPb } from '$lib/pb';
import { validateRouteParam } from '$lib/utils/filter';
import { error } from '@sveltejs/kit';

export const load: PageServerLoad = async ({ params }) => {
	let placeId: string;
	try {
		placeId = validateRouteParam(params.id);
	} catch {
		throw error(400, 'Invalid place ID');
	}

	const pb = createServerPb();

	let place: any;
	try {
		place = await pb.collection('places').getOne(placeId, {
			expand: 'placeType',
			fields: 'id,name,location,year,number,expand.placeType.type'
		});
		place.year = place.year ? place.year.split('-')[0] : place.year;
	} catch (e) {
		console.error('Place not found:', placeId, e);
		throw error(404, 'Place not found');
	}

	let rankings: any[] = [];
	try {
		const result = await pb.collection('rankings').getList(1, 500, {
			filter: `place = "${placeId}"`,
			expand: 'wrestler',
			sort: '-created',
			requestKey: `rankings-place-${placeId}`
		});
		rankings = result.items.sort((a: any, b: any) => {
			const na = parseInt(a.rank) || 0;
			const nb = parseInt(b.rank) || 0;
			if (na !== nb) return na - nb;
			return (a.rank2 || '').localeCompare(b.rank2 || '');
		});
	} catch (e) {
		console.error('Error loading rankings:', placeId, e);
	}

	return { place, rankings };
};
