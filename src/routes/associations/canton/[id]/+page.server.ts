import type { PageServerLoad } from './$types';
import { createServerPb } from '#lib/pb.js';
import { throwLoadError } from '#lib/utils/load-error.js';
import { validateRouteParam } from '#lib/utils/filter.js';
import { error } from '@sveltejs/kit';

export const load: PageServerLoad = async ({ params }) => {
	let cantonId: string;
	try {
		cantonId = validateRouteParam(params.id);
	} catch {
		throw error(400, 'Invalid canton ID');
	}

	const pb = createServerPb();

	try {
		const [canton, clubs] = await Promise.all([
			pb.collection('wrestlersByCanton').getFirstListItem(`id = "${cantonId}"`, {
				fields:
					'id,name,association,wrestlerAmount,wrestlerActive,wrestler1Star,wrestler2Star,wrestler3Star'
			}),
			pb.collection('wrestlersByClub').getFullList(200, {
				filter: `canton = "${cantonId}"`,
				sort: 'name',
				fields: 'id,name,wrestlerAmount,wrestlerActive,wrestler1Star,wrestler2Star,wrestler3Star'
			})
		]);

		return { canton, clubs };
	} catch (e) {
		throwLoadError(e, 'Canton not found');
	}
};
