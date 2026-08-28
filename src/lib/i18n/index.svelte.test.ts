import { describe, it, expect } from 'vitest';
import { t, delocalizePath, localizePath } from './index.svelte';

describe('t', () => {
	it('resolves a nested key for the given locale', () => {
		expect(t('de', 'nav.wrestler')).toBe('Schwinger');
		expect(t('fr', 'nav.wrestler')).toBe('Lutteurs');
	});

	it('returns the key itself when unresolved', () => {
		expect(t('de', 'nav.doesNotExist')).toBe('nav.doesNotExist');
		expect(t('de', 'doesNotExist')).toBe('doesNotExist');
	});
});

describe('delocalizePath', () => {
	it('strips the /fr prefix', () => {
		expect(delocalizePath('/fr/wrestler/123')).toBe('/wrestler/123');
	});

	it('maps bare /fr to /', () => {
		expect(delocalizePath('/fr')).toBe('/');
	});

	it('leaves unprefixed paths unchanged', () => {
		expect(delocalizePath('/wrestler/123')).toBe('/wrestler/123');
		expect(delocalizePath('/')).toBe('/');
	});

	it('does not strip paths that merely start with "fr" without the slash', () => {
		expect(delocalizePath('/frankfurt')).toBe('/frankfurt');
	});
});

describe('localizePath', () => {
	it('returns the unprefixed path for de', () => {
		expect(localizePath('/wrestler/123', 'de')).toBe('/wrestler/123');
		expect(localizePath('/fr/wrestler/123', 'de')).toBe('/wrestler/123');
		expect(localizePath('/fr', 'de')).toBe('/');
	});

	it('adds the /fr prefix for fr', () => {
		expect(localizePath('/wrestler/123', 'fr')).toBe('/fr/wrestler/123');
		expect(localizePath('/', 'fr')).toBe('/fr');
	});

	it('is idempotent when the path is already in the target locale', () => {
		expect(localizePath('/fr/wrestler/123', 'fr')).toBe('/fr/wrestler/123');
		expect(localizePath('/wrestler/123', 'de')).toBe('/wrestler/123');
	});

	it('round-trips fr -> de -> fr back to the original path', () => {
		const original = '/fr/wrestler/123';
		const de = localizePath(original, 'de');
		const backToFr = localizePath(de, 'fr');
		expect(backToFr).toBe(original);
	});
});
