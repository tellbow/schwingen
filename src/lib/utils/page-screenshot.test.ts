import { describe, it, expect } from 'vitest';
import { screenshotBase64 } from './page-screenshot';

describe('screenshotBase64', () => {
	it('is the data of an image data URL', () => {
		expect(screenshotBase64('data:image/jpeg;base64,/9j/4AAQ')).toBe('/9j/4AAQ');
	});

	it('leaves out what is no image or bigger than 4 MB', () => {
		expect(screenshotBase64('data:text/plain;base64,aGVsbG8=')).toBeUndefined();
		expect(screenshotBase64(`data:image/jpeg;base64,${'A'.repeat(5_600_000)}`)).toBeUndefined();
	});
});
