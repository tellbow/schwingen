import type { PageServerLoad } from './$types';
import { createServerPb } from '$lib/pb';
import { buildSafeFilter, sanitizeSort } from '$lib/utils/filter';
import { yearOnly } from '$lib/utils/format';

export const load: PageServerLoad = async ({ url }) => {
	const pb = createServerPb();
	const page = parseInt(url.searchParams.get('page') || '1');
	const perPage = 15;

	const filter = buildSafeFilter(url.searchParams, [
		{ param: 'result', column: 'result', match: 'equals' },
		{ param: 'points', column: 'points', match: 'equals' },
		{ param: 'round', column: 'fight_round', match: 'equals' },
		{ param: 'wrestlerName', column: 'wrestler.name', match: 'contains' },
		{ param: 'wrestlerVorname', column: 'wrestler.vorname', match: 'contains' },
		{ param: 'opponentName', column: 'opponent.name', match: 'contains' },
		{ param: 'opponentVorname', column: 'opponent.vorname', match: 'contains' },
		{ param: 'placeName', column: 'place.name', match: 'contains' },
		{ param: 'year', column: 'place.year', match: 'contains' }
	]);
	const sort = sanitizeSort(url.searchParams.get('sort'), '-place.year,-created');

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
				year: yearOnly(item.expand?.place?.year)
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
