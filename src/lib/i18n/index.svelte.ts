import { translations, type Locale } from './translations';

export { type Locale };

export const LOCALES: Locale[] = ['de', 'fr'];

export function t(locale: Locale, key: string): string {
	const parts = key.split('.');
	let val: unknown = translations[locale];
	for (const p of parts) {
		val = (val as Record<string, unknown>)?.[p];
	}
	return typeof val === 'string' ? val : key;
}

export function delocalizePath(pathname: string): string {
	if (pathname === '/fr') return '/';
	if (pathname.startsWith('/fr/')) return pathname.slice(3);
	return pathname;
}

export function localizePath(pathname: string, locale: Locale): string {
	const base = delocalizePath(pathname);
	if (locale === 'de') return base;
	return base === '/' ? '/fr' : `/fr${base}`;
}
