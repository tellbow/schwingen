let dark = $state(false);

export function getDark(): boolean {
	return dark;
}

export function toggleDark(): void {
	dark = !dark;
	applyDark();
	localStorage.setItem('dark-mode', String(dark));
}

export function initDark(): void {
	const saved = localStorage.getItem('dark-mode');
	dark =
		saved !== null ? saved === 'true' : window.matchMedia('(prefers-color-scheme: dark)').matches;
	applyDark();
}

function applyDark(): void {
	document.documentElement.classList.toggle('dark', dark);
}
