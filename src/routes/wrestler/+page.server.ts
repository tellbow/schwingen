import type { PageServerLoad } from './$types';
import { createServerPb } from '$lib/pb';
import {
	buildQuickSearchFilter,
	buildSafeFilter,
	sanitizeSort,
	WRESTLER_STATUS_FILTERS
} from '$lib/utils/filter';
import { yearOnly } from '$lib/utils/format';
import type { WrestlerRecord } from '$lib/types/pocketbase';

export const load: PageServerLoad = async ({ url }) => {
	const pb = createServerPb();
	const page = parseInt(url.searchParams.get('page') || '1');
	const perPage = 15;

	const safeFilter = buildSafeFilter(url.searchParams, [
		{ param: 'name', column: 'name', match: 'contains' },
		{ param: 'vorname', column: 'vorname', match: 'contains' },
		{ param: 'year', column: 'year', match: 'contains' },
		{ param: 'club', column: 'club.name', match: 'contains' },
		{ param: 'status', enum: WRESTLER_STATUS_FILTERS }
	]);
	const quickSearch = buildQuickSearchFilter(url.searchParams, ['name', 'vorname', 'club.name']);
	const filter = [safeFilter, quickSearch].filter(Boolean).join(' && ');
	const sort = sanitizeSort(url.searchParams.get('sort'), '-status.symbol,name,-created');

	try {
		const data = await pb.collection('wrestler').getList<WrestlerRecord>(page, perPage, {
			expand: 'club,status',
			filter,
			sort,
			fields: 'id,name,vorname,year,expand.club.id,expand.club.name,expand.status.symbol'
		});

		return {
			wrestlers: data.items.map((item) => ({
				...item,
				year: yearOnly(item.year)
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
