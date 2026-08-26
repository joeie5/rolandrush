// One-off script: migrates the 52 existing menu item media files from
// Supabase Storage (bucket `menu_items`) to Cloudflare R2 (bucket
// rolandrush-menu-media), then repoints menu_items.image_url/video_url at
// the new R2 public URLs. Does NOT delete anything from Supabase Storage
// until every migrated file is verified reachable from R2.
//
// Run once, locally, with your own credentials as env vars — never commit
// real values. Required:
//   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY   (service role needed: storage
//     listing + updating menu_items bypassing RLS)
//   R2_ACCOUNT_ID, R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY, R2_BUCKET_NAME,
//   R2_PUBLIC_URL
//
// Usage:
//   cd scripts/r2-migration && npm install
//   SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... R2_ACCOUNT_ID=... \
//   R2_ACCESS_KEY_ID=... R2_SECRET_ACCESS_KEY=... R2_BUCKET_NAME=rolandrush-menu-media \
//   R2_PUBLIC_URL=https://pub-fa2371744fd9484f890d032dcfbdcc5d.r2.dev \
//   node migrate.mjs
//
// Add DRY_RUN=1 to only list what would happen, without writing anything.
// Add DELETE_AFTER_VERIFY=1 to actually delete the Supabase Storage
// originals once every migrated URL is confirmed loading — omitted by
// default so a first run is always safe to inspect before committing.

import { createClient } from '@supabase/supabase-js';
import { S3Client, PutObjectCommand, DeleteObjectCommand } from '@aws-sdk/client-s3';

const SUPABASE_URL = requireEnv('SUPABASE_URL');
const SUPABASE_SERVICE_ROLE_KEY = requireEnv('SUPABASE_SERVICE_ROLE_KEY');
const R2_ACCOUNT_ID = requireEnv('R2_ACCOUNT_ID');
const R2_ACCESS_KEY_ID = requireEnv('R2_ACCESS_KEY_ID');
const R2_SECRET_ACCESS_KEY = requireEnv('R2_SECRET_ACCESS_KEY');
const R2_BUCKET_NAME = process.env.R2_BUCKET_NAME || 'rolandrush-menu-media';
const R2_PUBLIC_URL = requireEnv('R2_PUBLIC_URL').replace(/\/$/, '');
const SUPABASE_STORAGE_BUCKET = 'menu_items';
const DRY_RUN = process.env.DRY_RUN === '1';
const DELETE_AFTER_VERIFY = process.env.DELETE_AFTER_VERIFY === '1';

function requireEnv(name) {
  const v = process.env[name];
  if (!v) {
    console.error(`Missing required env var: ${name}`);
    process.exit(1);
  }
  return v;
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
const s3 = new S3Client({
  region: 'auto',
  endpoint: `https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
  credentials: { accessKeyId: R2_ACCESS_KEY_ID, secretAccessKey: R2_SECRET_ACCESS_KEY },
});

// storage.objects paths are {vendor_id}/{filename} — list vendor folders,
// then list files inside each.
async function listAllObjects() {
  const { data: vendorFolders, error } = await supabase.storage.from(SUPABASE_STORAGE_BUCKET).list('', { limit: 1000 });
  if (error) throw error;

  const allPaths = [];
  for (const entry of vendorFolders ?? []) {
    // Files at bucket root (no vendor folder) show up with `id` set;
    // folders show up with `id: null`.
    if (entry.id !== null) {
      allPaths.push(entry.name);
      continue;
    }
    const { data: files, error: filesError } = await supabase.storage
      .from(SUPABASE_STORAGE_BUCKET)
      .list(entry.name, { limit: 1000 });
    if (filesError) throw filesError;
    for (const f of files ?? []) {
      if (f.id !== null) allPaths.push(`${entry.name}/${f.name}`);
    }
  }
  return allPaths;
}

async function downloadFromSupabase(path) {
  const url = `${SUPABASE_URL}/storage/v1/object/public/${SUPABASE_STORAGE_BUCKET}/${path}`;
  const res = await fetch(url);
  if (!res.ok) throw new Error(`Download failed (${res.status}) for ${path}`);
  const contentType = res.headers.get('content-type') || 'application/octet-stream';
  const buf = Buffer.from(await res.arrayBuffer());
  return { buf, contentType };
}

async function uploadToR2(path, buf, contentType) {
  await s3.send(
    new PutObjectCommand({
      Bucket: R2_BUCKET_NAME,
      Key: path,
      Body: buf,
      ContentType: contentType,
    }),
  );
}

async function verifyR2Url(path) {
  const url = `${R2_PUBLIC_URL}/${path}`;
  const res = await fetch(url, { method: 'HEAD' });
  return res.ok;
}

async function repointMenuItemRow(path) {
  const oldUrl = `${SUPABASE_URL}/storage/v1/object/public/${SUPABASE_STORAGE_BUCKET}/${path}`;
  const newUrl = `${R2_PUBLIC_URL}/${path}`;

  const { data: byImage } = await supabase.from('menu_items').select('id').eq('image_url', oldUrl);
  for (const row of byImage ?? []) {
    if (!DRY_RUN) await supabase.from('menu_items').update({ image_url: newUrl }).eq('id', row.id);
    console.log(`  menu_items.${row.id}.image_url -> ${newUrl}`);
  }

  const { data: byVideo } = await supabase.from('menu_items').select('id').eq('video_url', oldUrl);
  for (const row of byVideo ?? []) {
    if (!DRY_RUN) await supabase.from('menu_items').update({ video_url: newUrl }).eq('id', row.id);
    console.log(`  menu_items.${row.id}.video_url -> ${newUrl}`);
  }

  return (byImage?.length ?? 0) + (byVideo?.length ?? 0);
}

async function main() {
  console.log(DRY_RUN ? '=== DRY RUN (no writes) ===' : '=== LIVE RUN ===');
  const paths = await listAllObjects();
  console.log(`Found ${paths.length} objects in Supabase Storage bucket "${SUPABASE_STORAGE_BUCKET}"`);

  const verified = [];
  const failed = [];

  for (const path of paths) {
    try {
      console.log(`\n${path}`);
      const { buf, contentType } = await downloadFromSupabase(path);
      console.log(`  downloaded ${buf.length} bytes (${contentType})`);

      if (!DRY_RUN) await uploadToR2(path, buf, contentType);
      console.log(`  ${DRY_RUN ? '[dry-run] would upload' : 'uploaded'} to r2://${R2_BUCKET_NAME}/${path}`);

      const ok = DRY_RUN ? true : await verifyR2Url(path);
      if (!ok) {
        failed.push(path);
        console.error(`  ✗ verification failed — R2 URL not reachable yet, skipping DB update and deletion for this file`);
        continue;
      }
      console.log(`  ✓ verified reachable at ${R2_PUBLIC_URL}/${path}`);

      const updated = await repointMenuItemRow(path);
      if (updated === 0) console.warn(`  (no menu_items row referenced this path — orphaned file, or already migrated)`);

      verified.push(path);
    } catch (err) {
      failed.push(path);
      console.error(`  ✗ ${err.message}`);
    }
  }

  console.log(`\n=== Summary ===`);
  console.log(`Verified + repointed: ${verified.length}`);
  console.log(`Failed: ${failed.length}`);
  if (failed.length) console.log(failed.map((p) => `  - ${p}`).join('\n'));

  if (DELETE_AFTER_VERIFY && !DRY_RUN) {
    if (failed.length > 0) {
      console.log('\nSkipping deletion — not all files verified. Fix failures and re-run before deleting.');
      return;
    }
    console.log(`\nDeleting ${verified.length} verified originals from Supabase Storage...`);
    for (const path of verified) {
      await supabase.storage.from(SUPABASE_STORAGE_BUCKET).remove([path]);
      console.log(`  deleted ${path}`);
    }
  } else if (!DRY_RUN) {
    console.log('\nNot deleting Supabase Storage originals (DELETE_AFTER_VERIFY not set). Re-run with DELETE_AFTER_VERIFY=1 once you\'ve spot-checked the R2 URLs yourself.');
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
