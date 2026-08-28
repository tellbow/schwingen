import type { PageServerLoad } from './$types';
import { createServerPb } from '$lib/pb';
import { buildSafeFilter, escapeFilterValue, sanitizeSort } from '$lib/utils/filter';

export const load: PageServerLoad = async ({ url }) => {
	const pb = createServerPb();
	const page = parseInt(url.searchParams.get('page') || '1');
	const perPage = 15;

	const safeFilter = buildSafeFilter(url.searchParams, [
		{ param: 'rank', column: 'rank', match: 'equals' },
		{ param: 'points', column: 'points', match: 'equals' },
		{ param: 'final', column: 'final', match: 'boolean' },
		{ param: 'wreath', column: 'wreath', match: 'boolean' },
		{ param: 'wrestlerName', column: 'wrestler.name', match: 'contains' },
		{ param: 'wrestlerVorname', column: 'wrestler.vorname', match: 'contains' },
		{ param: 'placeName', column: 'place.name', match: 'contains' }
	]);
	const yearValue = url.searchParams.get('year');
	const escapedYear = yearValue ? escapeFilterValue(yearValue) : '';
	const yearFilter = escapedYear ? `place.year >= "2015" && place.year ~ "${escapedYear}"` : '';
	const filter = [safeFilter, yearFilter].filter(Boolean).join(' && ');

	const sort = sanitizeSort(url.searchParams.get('sort'), '-place.year,-created');

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
