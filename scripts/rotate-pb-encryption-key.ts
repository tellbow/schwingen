import { Database } from 'bun:sqlite';

const [dbPath] = process.argv.slice(2);
const oldKey = process.env.OLD_PB_ENCRYPTION_KEY ?? '';
const newKey = process.env.NEW_PB_ENCRYPTION_KEY ?? '';
if (!dbPath || oldKey.length !== 32 || newKey.length !== 32) {
	console.error(
		'usage: OLD_PB_ENCRYPTION_KEY=… NEW_PB_ENCRYPTION_KEY=… bun scripts/rotate-pb-encryption-key.ts data.db'
	);
	process.exit(1);
}

const importKey = (key: string) =>
	crypto.subtle.importKey('raw', new TextEncoder().encode(key), 'AES-GCM', false, [
		'encrypt',
		'decrypt'
	]);

const db = new Database(dbPath);
const row = db.query("SELECT value FROM _params WHERE id = 'settings'").get() as {
	value: string;
} | null;
if (!row) throw new Error('no settings row in _params');

const raw = Buffer.from(String(row.value), 'base64');
const plain = await crypto.subtle.decrypt(
	{ name: 'AES-GCM', iv: raw.subarray(0, 12) },
	await importKey(oldKey),
	raw.subarray(12)
);

const settings = JSON.parse(new TextDecoder().decode(plain));
const filled = (value: unknown) => typeof value === 'string' && value !== '';
console.log('credentials in settings (values not shown):', {
	smtpPassword: filled(settings.smtp?.password),
	s3Secret: filled(settings.s3?.secret),
	backupsS3Secret: filled(settings.backups?.s3?.secret)
});

const iv = crypto.getRandomValues(new Uint8Array(12));
const sealed = await crypto.subtle.encrypt({ name: 'AES-GCM', iv }, await importKey(newKey), plain);
db.query("UPDATE _params SET value = ? WHERE id = 'settings'").run(
	Buffer.concat([iv, new Uint8Array(sealed)]).toString('base64')
);
db.close();
console.log('settings re-encrypted with the new key');
