import type { PageServerLoad } from './$types';
import { createServerPb } from '$lib/pb';

export const load: PageServerLoad = async ({ url }) => {
	const pb = createServerPb();
	const page = parseInt(url.searchParams.get('page') || '1');
	const perPage = 15;
	const filter = url.searchParams.get('filter') || '';
	const sort = url.searchParams.get('sort') || '-place.year,-created';

	try {
		const data = await pb.collection('rankings').getList(page, perPage, {
			expand: 'wrestler,place',
			filter,
			sort,
			fields:
				'id,rank,rank2,points,final,result,wreath,status,expand.wrestler.id,expand.wrestler.name,expand.wrestler.vorname,expand.place.id,expand.place.name,expand.place.year'
		});

		return {
			rankings: data.items.map((item: any) => ({
				...item,
				year: item.expand?.place?.year?.substring(0, 4) || ''
			})),
			total: data.totalItems,
			page,
			perPage
		};
	} catch (e) {
		console.error('Error loading rankings:', e);
		return { rankings: [], total: 0, page, perPage };
	}
};
