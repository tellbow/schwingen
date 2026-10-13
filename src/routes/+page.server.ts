import type { PageServerLoad } from './$types';
import { createServerPb } from '$lib/pb';
import type { EloRecord } from '$lib/types/pocketbase';

const ELO_YEAR = '2026';

export const load: PageServerLoad = async () => {
	const pb = createServerPb();

	try {
		const data = await pb.collection(`elo${ELO_YEAR}`).getList<EloRecord>(1, 5, {
			expand: 'wrestler',
			sort: '-rating',
			fields: 'id,rating,expand.wrestler.id,expand.wrestler.name,expand.wrestler.vorname',
			skipTotal: true
		});

		return {
			eloYear: ELO_YEAR,
			eloTop5: data.items.map((item) => ({
				id: item.expand?.wrestler?.id ?? item.id,
				name: item.expand?.wrestler?.name ?? '',
				vorname: item.expand?.wrestler?.vorname ?? '',
				rating: item.rating
			}))
		};
	} catch (e) {
		console.error('Error loading homepage ELO data:', e);
		return { eloYear: ELO_YEAR, eloTop5: [] };
	}
};
