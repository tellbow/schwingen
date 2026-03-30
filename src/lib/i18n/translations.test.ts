import { describe, it, expect } from 'vitest';
import { translations } from './translations';
import type { Locale } from './translations';

const LOCALES: Locale[] = ['de', 'fr'];

const REQUIRED_KEYS: Record<string, string[]> = {
	nav: ['wrestler', 'places', 'rankings', 'bouts', 'statistics', 'head2head', 'associations'],
	common: ['loading', 'back', 'noResults', 'search', 'page', 'of', 'filter'],
	wrestler: ['title', 'name', 'firstName', 'yearOfBirth', 'club', 'status'],
	places: ['title', 'name', 'type', 'location'],
	rankings: ['title', 'rank', 'points', 'wreath', 'result'],
	bouts: ['title', 'round', 'result', 'points', 'opponent'],
	statistics: ['title'],
	head2head: ['title', 'wins', 'losses', 'draws', 'total'],
	associations: ['title']
};

describe('translations', () => {
	it('has entries for all locales', () => {
		for (const locale of LOCALES) {
			expect(translations[locale]).toBeDefined();
		}
	});

	for (const locale of LOCALES) {
		describe(`locale: ${locale}`, () => {
			for (const [section, keys] of Object.entries(REQUIRED_KEYS)) {
				describe(`section: ${section}`, () => {
					for (const key of keys) {
						it(`has non-empty string for "${key}"`, () => {
							const value = translations[locale][section]?.[key];
							expect(typeof value).toBe('string');
							expect(value.length).toBeGreaterThan(0);
						});
					}
				});
			}
		});
	}

	it('de and fr have identical key structure', () => {
		const deSections = Object.keys(translations.de).sort();
		const frSections = Object.keys(translations.fr).sort();
		expect(deSections).toEqual(frSections);

		for (const section of deSections) {
			const deKeys = Object.keys(translations.de[section]).sort();
			const frKeys = Object.keys(translations.fr[section]).sort();
			expect(deKeys).toEqual(frKeys);
		}
	});

	it('de and fr translations differ (not identical strings)', () => {
		let differenceFound = false;
		for (const section of Object.keys(translations.de)) {
			for (const key of Object.keys(translations.de[section])) {
				if (translations.de[section][key] !== translations.fr[section][key]) {
					differenceFound = true;
					break;
				}
			}
			if (differenceFound) break;
		}
		expect(differenceFound).toBe(true);
	});
});
