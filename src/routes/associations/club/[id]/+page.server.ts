import type { PageServerLoad } from './$types';
import { createServerPb } from '$lib/pb';
import { buildSafeFilter, validateRouteParam, WRESTLER_STATUS_FILTERS } from '$lib/utils/filter';
import { yearOnly } from '$lib/utils/format';
import { error } from '@sveltejs/kit';
import type { ClubStatsRecord, WrestlerRecord } from '$lib/types/pocketbase';

export const load: PageServerLoad = async ({ params, url }) => {
	let clubId: string;
	try {
		clubId = validateRouteParam(params.id);
	} catch {
		throw error(400, 'Invalid club ID');
	}

	const pb = createServerPb();
	const page = parseInt(url.searchParams.get('page') || '1');
	const perPage = 15;

	const memberFilter = buildSafeFilter(url.searchParams, [
		{ param: 'name', column: 'name', match: 'contains' },
		{ param: 'vorname', column: 'vorname', match: 'contains' },
		{ param: 'year', column: 'year', match: 'contains' },
		{ param: 'status', enum: WRESTLER_STATUS_FILTERS }
	]);
	const filter = [`club.id = "${clubId}"`, memberFilter].filter(Boolean).join(' && ');

	try {
		const [club, wrestlers] = await Promise.all([
			pb
				.collection('wrestlersByClub')
				.getFirstListItem<ClubStatsRecord>(`id = "${clubId}"`, {
					fields:
						'id,name,canton,wrestlerAmount,wrestlerActive,wrestler1Star,wrestler2Star,wrestler3Star'
				})
				.catch(() => null),
			pb.collection('wrestler').getList<WrestlerRecord>(page, perPage, {
				filter,
				expand: 'status',
				sort: '-status.symbol,name,-created',
				fields: 'id,name,vorname,year,expand.status.symbol'
			})
		]);

		return {
			club,
			wrestlers: wrestlers.items.map((item) => ({
				...item,
				year: yearOnly(item.year)
			})),
			total: wrestlers.totalItems,
			page,
			perPage
		};
	} catch (e) {
		console.error(e);
		throw error(404, 'Club not found');
	}
};
