import type { PageServerLoad } from './$types';
import { createServerPb } from '$lib/pb';
import { validateRouteParam } from '$lib/utils/filter';
import { error } from '@sveltejs/kit';

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
	const filter = url.searchParams.get('filter') || '';

	const baseFilter = `club.id = "${clubId}"${filter ? ` && ${filter}` : ''}`;

	try {
		const [club, wrestlers] = await Promise.all([
			pb.collection('wrestlersByClub').getFirstListItem(`id = "${clubId}"`, {
				fields: 'id,name,canton,wrestlerAmount,wrestlerActive,wrestler1Star,wrestler2Star,wrestler3Star'
			}).catch(() => null),
			pb.collection('wrestler').getList(page, perPage, {
				filter: baseFilter,
				expand: 'status',
				sort: '-status.symbol,name,-created',
				fields: 'id,name,vorname,year,expand.status.symbol'
			})
		]);

		return {
			club,
			wrestlers: wrestlers.items.map((item: any) => ({
				...item,
				year: item.year ? item.year.split('-')[0] : item.year
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
