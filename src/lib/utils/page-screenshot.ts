export const MAX_SCREENSHOT_BYTES = 4 * 1024 * 1024;

export async function pageScreenshot(): Promise<string | undefined> {
	try {
		const { toJpeg } = await import('html-to-image');
		const options = {
			pixelRatio: 1,
			backgroundColor: getComputedStyle(document.body).backgroundColor,
			filter: (node: Node) => !(node instanceof HTMLElement && node.dataset.bugReport !== undefined)
		};
		await toJpeg(document.body, options);
		for (const quality of [0.8, 0.5]) {
			const shot = await toJpeg(document.body, { ...options, quality });
			if (screenshotBase64(shot)) return shot;
		}
		return undefined;
	} catch {
		return undefined;
	}
}

export function screenshotBase64(dataUrl: string): string | undefined {
	const base64 = dataUrl.slice(dataUrl.indexOf(',') + 1);
	if (!dataUrl.startsWith('data:image/') || (base64.length * 3) / 4 > MAX_SCREENSHOT_BYTES) {
		return undefined;
	}
	return base64;
}
