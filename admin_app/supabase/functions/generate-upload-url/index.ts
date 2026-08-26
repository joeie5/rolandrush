// Presigned-upload-URL issuer for menu item media (R2).
//
// Never returns R2 credentials to the client — only a short-lived presigned
// PUT URL for one specific object key, plus the public URL it will be
// reachable at once uploaded. R2 credentials live only as Edge Function
// secrets (R2_ACCESS_KEY_ID / R2_SECRET_ACCESS_KEY / R2_ACCOUNT_ID /
// R2_BUCKET_NAME / R2_PUBLIC_URL), set via `supabase secrets set`.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.4';
import { AwsClient } from 'https://esm.sh/aws4fetch@1.0.17';

const ALLOWED_CONTENT_TYPES: Record<string, 'image' | 'video'> = {
  'image/jpeg': 'image',
  'image/png': 'image',
  'image/webp': 'image',
  'video/mp4': 'video',
  'video/quicktime': 'video',
};

const PRESIGN_EXPIRY_SECONDS = 10 * 60;

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  const authHeader = req.headers.get('Authorization');
  if (!authHeader) return json({ error: 'Missing Authorization header' }, 401);

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    { global: { headers: { Authorization: authHeader } } },
  );

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) return json({ error: 'Not authenticated' }, 401);

  // Only vendors can request menu-media upload URLs — riders/customers hold
  // no vendor_profiles row, so this cheaply rejects them.
  const { data: vendor, error: vendorError } = await supabase
    .from('vendor_profiles')
    .select('id')
    .eq('user_id', userData.user.id)
    .maybeSingle();
  if (vendorError || !vendor) return json({ error: 'Not a vendor account' }, 403);

  let body: { fileName?: string; contentType?: string; mediaType?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error: 'Invalid JSON body' }, 400);
  }

  const { contentType, mediaType } = body;
  if (!contentType || !mediaType) return json({ error: 'fileName, contentType and mediaType are required' }, 400);

  const resolvedKind = ALLOWED_CONTENT_TYPES[contentType];
  if (!resolvedKind) return json({ error: `Unsupported content-type: ${contentType}` }, 400);
  if (resolvedKind !== mediaType) return json({ error: `contentType ${contentType} does not match mediaType ${mediaType}` }, 400);

  const accountId = Deno.env.get('R2_ACCOUNT_ID')!;
  const bucket = Deno.env.get('R2_BUCKET_NAME')!;
  const publicUrl = Deno.env.get('R2_PUBLIC_URL')!;
  const accessKeyId = Deno.env.get('R2_ACCESS_KEY_ID')!;
  const secretAccessKey = Deno.env.get('R2_SECRET_ACCESS_KEY')!;

  // Matches the existing {vendor_id}/{timestamp}_main (video) /
  // {timestamp}_thumb (image) convention from the pre-R2 upload flow, so
  // migrated and freshly-uploaded files look identical in storage.
  const timestamp = Date.now();
  const suffix = mediaType === 'video' ? 'main' : 'thumb';
  const objectKey = `${vendor.id}/${timestamp}_${suffix}`;

  const s3 = new AwsClient({
    accessKeyId,
    secretAccessKey,
    service: 's3',
    region: 'auto',
  });

  const objectUrl = new URL(`https://${accountId}.r2.cloudflarestorage.com/${bucket}/${objectKey}`);
  objectUrl.searchParams.set('X-Amz-Expires', String(PRESIGN_EXPIRY_SECONDS));

  const signed = await s3.sign(objectUrl, {
    method: 'PUT',
    headers: { 'content-type': contentType },
    aws: { signQuery: true },
  });

  return json({
    uploadUrl: signed.url,
    publicUrl: `${publicUrl}/${objectKey}`,
  });
});
