import type { PageServerLoad } from './$types';
import { createServerPb } from '$lib/pb';
import { validateRouteParam } from '$lib/utils/filter';
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
				fields: 'id,name,association,wrestlerAmount,wrestlerActive,wrestler1Star,wrestler2Star,wrestler3Star'
			}).catch(() => null),
			pb.collection('wrestlersByClub').getFullList(200, {
				filter: `canton = "${cantonId}"`,
				sort: 'name',
				fields: 'id,name,wrestlerAmount,wrestlerActive,wrestler1Star,wrestler2Star,wrestler3Star'
			}).catch(() => [])
		]);

		return { canton, clubs };
	} catch (e) {
		console.error(e);
		throw error(404, 'Canton not found');
	}
};
