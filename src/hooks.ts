import type { Reroute } from '@sveltejs/kit/hooks';

export const reroute: Reroute = ({ url }) => {
	if (url.pathname === '/fr') return '/';
	if (url.pathname.startsWith('/fr/')) return url.pathname.slice(3);
};
