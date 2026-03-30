import type { PageServerLoad } from './$types';
import { createServerPb } from '$lib/pb';

export const load: PageServerLoad = async ({ url }) => {
	const pb = createServerPb();
	const page = parseInt(url.searchParams.get('page') || '1');
	const perPage = 15;

	const filter = url.searchParams.get('filter') || '';
	const sort = url.searchParams.get('sort') || '-status.symbol,name,-created';

	try {
		const data = await pb.collection('wrestler').getList(page, perPage, {
			expand: 'club,status',
			filter,
			sort,
			fields: 'id,name,vorname,year,expand.club.id,expand.club.name,expand.status.symbol'
		});

		return {
			wrestlers: data.items.map((item: any) => ({
				...item,
				year: item.year ? item.year.split('-')[0] : item.year
			})),
			total: data.totalItems,
			page,
			perPage
		};
	} catch (e) {
		console.error('Error loading wrestlers:', e);
		return { wrestlers: [], total: 0, page, perPage };
	}
};
