import type { PageServerLoad } from './$types';
import { createServerPb } from '$lib/pb';

export const load: PageServerLoad = async ({ url }) => {
	const pb = createServerPb();
	const page = parseInt(url.searchParams.get('page') || '1');
	const perPage = 15;
	const filter = url.searchParams.get('filter') || '';
	const sort = url.searchParams.get('sort') || '-place.year,-created';

	try {
		const data = await pb.collection('bouts').getList(page, perPage, {
			expand: 'wrestler,opponent,place',
			filter,
			sort,
			fields:
				'id,result,points,fight_round,expand.wrestler.id,expand.wrestler.name,expand.wrestler.vorname,expand.opponent.id,expand.opponent.name,expand.opponent.vorname,expand.place.id,expand.place.name,expand.place.year'
		});

		return {
			bouts: data.items.map((item: any) => ({
				...item,
				year: item.expand?.place?.year?.split('-')[0] || ''
			})),
			total: data.totalItems,
			page,
			perPage
		};
	} catch (e) {
		console.error('Error loading bouts:', e);
		return { bouts: [], total: 0, page, perPage };
	}
};
