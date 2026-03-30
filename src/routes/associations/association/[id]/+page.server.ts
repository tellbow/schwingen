import type { PageServerLoad } from './$types';
import { createServerPb } from '$lib/pb';
import { validateRouteParam } from '$lib/utils/filter';
import { error } from '@sveltejs/kit';

export const load: PageServerLoad = async ({ params }) => {
	let assocId: string;
	try {
		assocId = validateRouteParam(params.id);
	} catch {
		throw error(400, 'Invalid association ID');
	}

	const pb = createServerPb();

	try {
		const [association, cantons] = await Promise.all([
			pb.collection('wrestlersByAssociation').getFirstListItem(`id = "${assocId}"`, {
				fields: 'id,name,abbreviation,wrestlerAmount,wrestlerActive,wrestler1Star,wrestler2Star,wrestler3Star'
			}).catch(() => null),
			pb.collection('wrestlersByCanton').getFullList(50, {
				filter: `association = "${assocId}"`,
				sort: 'name',
				fields: 'id,name,wrestlerAmount,wrestlerActive,wrestler1Star,wrestler2Star,wrestler3Star'
			}).catch(() => [])
		]);

		return { association, cantons };
	} catch (e) {
		console.error(e);
		throw error(404, 'Association not found');
	}
};
