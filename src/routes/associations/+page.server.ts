import type { PageServerLoad } from './$types';
import { createServerPb } from '$lib/pb';
import type {
	AssociationStatsRecord,
	CantonStatsRecord,
	ClubStatsRecord
} from '$lib/types/pocketbase';

export const load: PageServerLoad = async () => {
	const pb = createServerPb();

	try {
		const [associations, cantons, clubs] = await Promise.all([
			pb.collection('wrestlersByAssociation').getFullList<AssociationStatsRecord>(10, {
				sort: 'name',
				fields:
					'id,name,abbreviation,wrestlerAmount,wrestlerActive,wrestler1Star,wrestler2Star,wrestler3Star'
			}),
			pb.collection('wrestlersByCanton').getFullList<CantonStatsRecord>(50, {
				sort: 'name',
				fields:
					'id,name,association,wrestlerAmount,wrestlerActive,wrestler1Star,wrestler2Star,wrestler3Star'
			}),
			pb.collection('wrestlersByClub').getFullList<ClubStatsRecord>(500, {
				sort: 'name',
				fields:
					'id,name,canton,wrestlerAmount,wrestlerActive,wrestler1Star,wrestler2Star,wrestler3Star'
			})
		]);

		return { associations, cantons, clubs };
	} catch (e) {
		console.error('Error loading associations:', e);
		return { associations: [], cantons: [], clubs: [] };
	}
};
