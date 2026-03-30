import type { PageServerLoad } from './$types';
import { createServerPb } from '$lib/pb';

export const load: PageServerLoad = async ({ url }) => {
	const pb = createServerPb();
	const page = parseInt(url.searchParams.get('page') || '1');
	const perPage = 15;
	const filter = url.searchParams.get('filter') || '';
	const sort = url.searchParams.get('sort') || '-year,-created';

	try {
		const data = await pb.collection('places').getList(page, perPage, {
			expand: 'placeType',
			filter,
			sort,
			fields: 'id,number,name,location,year,expand.placeType.type'
		});

		return {
			places: data.items.map((item: any) => ({
				...item,
				yearDisplay: item.year ? item.year.split('-')[0] : item.year
			})),
			total: data.totalItems,
			page,
			perPage
		};
	} catch (e) {
		console.error('Error loading places:', e);
		return { places: [], total: 0, page, perPage };
	}
};
