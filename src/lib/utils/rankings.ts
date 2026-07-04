export interface RankingBout {
	id: string;
	wrestler: string;
	[key: string]: unknown;
}

export function groupBoutsByWrestler(bouts: RankingBout[]): Map<string, RankingBout[]> {
	const map = new Map<string, RankingBout[]>();
	for (const bout of bouts) {
		const list = map.get(bout.wrestler);
		if (list) {
			list.push(bout);
		} else {
			map.set(bout.wrestler, [bout]);
		}
	}
	return map;
}
