#!/usr/bin/env bun
/**
 * Start script that runs both PocketBase and SvelteKit servers
 */

import { resolve } from 'path';

const isProd = process.argv.includes('--prod');
const pbUrl = process.env.PB_URL || 'http://localhost:8090';

// Find PocketBase binary
const pbBinary = process.env.PB_BINARY || '/opt/homebrew/bin/pocketbase';

const pbDataDir = resolve(import.meta.dir, 'pb_data');

console.log(`Starting PocketBase at ${pbUrl}...`);
console.log(`PocketBase data dir: ${pbDataDir}`);

// Start PocketBase
const pb = Bun.spawn(
	[
		pbBinary,
		'serve',
		'--http=0.0.0.0:8090',
		`--dir=${pbDataDir}`,
		'--encryptionEnv=PB_ENCRYPTION_KEY'
	],
	{
		stdout: 'pipe',
		stderr: 'pipe',
		env: { ...process.env }
	}
);

// Pipe PocketBase output with prefix
const pbReader = pb.stdout.getReader();
const pbErrReader = pb.stderr.getReader();

async function readPipe(reader: ReadableStreamDefaultReader<Uint8Array>, prefix: string) {
	const decoder = new TextDecoder();
	while (true) {
		const { done, value } = await reader.read();
		if (done) break;
		const text = decoder.decode(value);
		for (const line of text.split('\n')) {
			if (line.trim()) console.log(`${prefix} ${line}`);
		}
	}
}

readPipe(pbReader, '[PocketBase]').catch(console.error);
readPipe(pbErrReader, '[PocketBase ERR]').catch(console.error);

// Wait for PocketBase to be ready (health check loop)
const pbHealthUrl = `http://127.0.0.1:8090/api/health`;
let pbReady = false;
for (let i = 0; i < 30; i++) {
	try {
		const res = await fetch(pbHealthUrl);
		if (res.ok) {
			pbReady = true;
			break;
		}
	} catch {
		/* not up yet */
	}
	await Bun.sleep(500);
}
if (!pbReady) {
	console.error('PocketBase did not become ready in time. Exiting.');
	pb.kill();
	process.exit(1);
}

if (isProd) {
	// Production: run the built SvelteKit server
	console.log('Starting SvelteKit server (production)...');
	const sk = Bun.spawn(['bun', resolve(import.meta.dir, 'build/index.js')], {
		stdout: 'inherit',
		stderr: 'inherit',
		env: {
			...process.env,
			PORT: process.env.PORT || '3000',
			PB_URL: pbUrl
		}
	});
	await sk.exited;
} else {
	// Development: run Vite dev server
	console.log('Starting SvelteKit dev server...');
	const sk = Bun.spawn(['bunx', '--bun', 'vite', 'dev'], {
		stdout: 'inherit',
		stderr: 'inherit',
		env: {
			...process.env,
			PB_URL: pbUrl
		}
	});
	await sk.exited;
}

pb.kill();
