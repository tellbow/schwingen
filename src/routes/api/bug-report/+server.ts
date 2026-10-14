import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { env } from '$env/dynamic/private';
import {
	BUG_REPORT_LIMITS,
	RateLimiter,
	isHoneypotFilled,
	openIssue,
	parseBugReport
} from '$lib/server/bug-report';

const limiter = new RateLimiter(5, 60, 60 * 60 * 1000);

export const POST: RequestHandler = async ({ request, fetch, getClientAddress }) => {
	const token = env.GITHUB_FEEDBACK_TOKEN;
	const repo = env.GITHUB_FEEDBACK_REPO;
	if (!token || !repo) return json({ error: 'unavailable' }, { status: 503 });

	const text = await request.text();
	if (text.length > BUG_REPORT_LIMITS.body) return json({ error: 'too large' }, { status: 413 });
	let value: unknown;
	try {
		value = JSON.parse(text);
	} catch {
		return json({ error: 'invalid' }, { status: 400 });
	}
	if (isHoneypotFilled(value)) return json({ ok: true }, { status: 201 });
	const report = parseBugReport(value, __APP_VERSION__);
	if (!report) return json({ error: 'invalid' }, { status: 400 });

	const address = getClientAddress();
	if (!limiter.take(address)) return json({ error: 'busy' }, { status: 429 });
	try {
		await openIssue(fetch, repo, token, report);
	} catch (error) {
		limiter.refund(address);
		console.error('bug report: no issue', error);
		return json({ error: 'github' }, { status: 502 });
	}
	return json({ ok: true }, { status: 201 });
};
