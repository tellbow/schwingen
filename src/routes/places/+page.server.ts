import type { PageServerLoad } from './$types';
import { createServerPb } from '$lib/pb';
import { buildQuickSearchFilter, buildSafeFilter, sanitizeSort } from '$lib/utils/filter';

export const load: PageServerLoad = async ({ url }) => {
	const pb = createServerPb();
	const page = parseInt(url.searchParams.get('page') || '1');
	const perPage = 15;

	const safeFilter = buildSafeFilter(url.searchParams, [
		{ param: 'number', column: 'number', match: 'contains' },
		{ param: 'name', column: 'name', match: 'contains' },
		{ param: 'location', column: 'location', match: 'contains' },
		{ param: 'year', column: 'year', match: 'contains' },
		{ param: 'type', column: 'placeType.type', match: 'equals' }
	]);
	const quickSearch = buildQuickSearchFilter(url.searchParams, ['name', 'location']);
	const filter = [safeFilter, quickSearch].filter(Boolean).join(' && ');
	const sort = sanitizeSort(url.searchParams.get('sort'), '-year,-created');

	try {
		const data = await pb.collection('places').getList(page, perPage, {
			expand: 'placeType',
			filter,
			sort,
			fields: 'id,number,name,location,year,expand.placeType.type'
		});

		return {
			places: data.items,
			total: data.totalItems,
			page,
			perPage
		};
	} catch (e) {
		console.error('Error loading places:', e);
		return { places: [], total: 0, page, perPage };
	}
};
