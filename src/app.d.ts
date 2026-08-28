import type { Locale } from '$lib/i18n/translations';

declare const process: {
	env?: Record<string, string | undefined>;
};

declare global {
	namespace App {
		interface Locals {
			locale: Locale;
		}
	}
}

export {};
