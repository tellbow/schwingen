import type { RequestHandler } from './$types';
import { GITHUB_FEEDBACK_TOKEN, GITHUB_FEEDBACK_REPO } from '$app/env/private';
import {
	BUG_REPORT_LIMITS,
	RateLimiter,
	isHoneypotFilled,
	openIssue,
	parseBugReport
} from '#lib/server/bug-report.js';

const limiter = new RateLimiter(5, 60, 60 * 60 * 1000);

export const POST: RequestHandler = async ({ request, fetch, getClientAddress }) => {
	const token = GITHUB_FEEDBACK_TOKEN;
	const repo = GITHUB_FEEDBACK_REPO;
	if (!token || !repo) return Response.json({ error: 'unavailable' }, { status: 503 });

	const text = await request.text();
	if (text.length > BUG_REPORT_LIMITS.body)
		return Response.json({ error: 'too large' }, { status: 413 });
	let value: unknown;
	try {
		value = JSON.parse(text);
	} catch {
		return Response.json({ error: 'invalid' }, { status: 400 });
	}
	if (isHoneypotFilled(value)) return Response.json({ ok: true }, { status: 201 });
	const report = parseBugReport(value, __APP_VERSION__);
	if (!report) return Response.json({ error: 'invalid' }, { status: 400 });

	const address = getClientAddress();
	if (!limiter.take(address)) return Response.json({ error: 'busy' }, { status: 429 });
	try {
		await openIssue(fetch, repo, token, report);
	} catch (error) {
		limiter.refund(address);
		console.error('bug report: no issue', error);
		return Response.json({ error: 'github' }, { status: 502 });
	}
	return Response.json({ ok: true }, { status: 201 });
};
