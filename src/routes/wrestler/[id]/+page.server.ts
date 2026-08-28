import type { PageServerLoad } from './$types';
import { createServerPb } from '$lib/pb';
import { validateRouteParam } from '$lib/utils/filter';
import { yearOnly } from '$lib/utils/format';
import { error } from '@sveltejs/kit';

export const load: PageServerLoad = async ({ params }) => {
	let wrestlerId: string;
	try {
		wrestlerId = validateRouteParam(params.id);
	} catch {
		throw error(400, 'Invalid wrestler ID');
	}

	const pb = createServerPb();

	try {
		const wrestler = await pb.collection('wrestler').getFirstListItem(`id="${wrestlerId}"`, {
			expand: 'status,metadata,club,club.canton,club.canton.association',
			fields:
				'id,name,vorname,year,category,expand.status.status,expand.metadata.website,expand.club.id,expand.club.name,expand.club.expand.canton.name,expand.club.expand.canton.expand.association.abbreviation'
		});

		wrestler.year = yearOnly(wrestler.year) || '-';

		return { wrestler };
	} catch {
		throw error(404, 'Wrestler not found');
	}
};
