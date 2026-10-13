export function groupBoutsByWrestler<T extends { wrestler: string }>(bouts: T[]): Map<string, T[]> {
	const map = new Map<string, T[]>();
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
