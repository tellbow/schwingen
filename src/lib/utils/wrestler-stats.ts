export interface BoutCounts {
	win: number;
	draw: number;
	loss: number;
}

export function computeBoutCounts(rankingsData: any[]): BoutCounts {
	return rankingsData.reduce(
		(acc: BoutCounts, { result }: any) => ({
			win: acc.win + (result.match(/\+/g) || []).length,
			draw: acc.draw + (result.match(/-/g) || []).length,
			loss: acc.loss + (result.match(/o/g) || []).length
		}),
		{ win: 0, draw: 0, loss: 0 }
	);
}

export function computeAverageRank(rankingsData: any[]): string {
	const filtered = rankingsData.filter((r: any) => r.status !== 'Unfall');
	if (filtered.length < 5) return '-';
	const total = filtered.reduce(
		(s: number, r: any) => s + (parseInt(r.rank.replace(/\D/g, '')) || 0),
		0
	);
	return (total / filtered.length).toFixed(2);
}

export function computeAveragePoints(rankingsData: any[]): string {
	const filtered = rankingsData.filter(
		(r: any) =>
			r.status !== 'Unfall' && !r.expand?.place?.expand?.placeType?.type?.includes('idgenössisch')
	);
	if (filtered.length < 5) return '-';
	const total = filtered.reduce((s: number, r: any) => s + (parseFloat(r.points) || 0), 0);
	return (total / filtered.length).toFixed(2);
}

export function computeWinRate(counts: BoutCounts): number {
	const total = counts.win + counts.draw + counts.loss;
	return total > 0 ? Math.round((counts.win / total) * 100) : 0;
}
