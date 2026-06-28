import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

type ResetPasswordBody = {
  userId?: string;
  temporaryPassword?: string;
};

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') {
    return jsonResponse({ success: true }, 200);
  }

  if (request.method !== 'POST') {
    return jsonResponse(failure('Only POST requests are supported.'), 405);
  }

  const admin = createServiceClient();
  if (!admin) {
    return jsonResponse(failure('Admin service is not configured.'), 500);
  }

  const isAdmin = await verifyAdminCaller(request, admin);
  if (!isAdmin) {
    return jsonResponse(failure('Only admins can perform this action.'), 403);
  }

  const body = await readJsonBody<ResetPasswordBody>(request);
  const userId = body?.userId?.trim();
  const password = body?.temporaryPassword ?? '';

  if (!userId || password.length < 6) {
    return jsonResponse(
      failure('User and a temporary password of at least 6 characters are required.'),
      400,
    );
  }

  const { error: authError } = await admin.auth.admin.updateUserById(userId, {
    password,
  });

  if (authError) {
    return jsonResponse(failure('Unable to reset password for this user.'), 200);
  }

  await admin
    .from('app_users')
    .update({ is_first_login: true, password_changed_once: false })
    .eq('id', userId);

  return jsonResponse({
    success: true,
    message: 'Temporary password set successfully.',
  });
});

function createServiceClient() {
  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

  if (!supabaseUrl || !serviceRoleKey) {
    return null;
  }

  return createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false },
  });
}

async function verifyAdminCaller(
  request: Request,
  admin: ReturnType<typeof createClient>,
): Promise<boolean> {
  const token = readBearerToken(request);
  if (!token) {
    return false;
  }

  const { data, error } = await admin.auth.getUser(token);
  if (error || !data.user) {
    return false;
  }

  const { data: appUser } = await admin
    .from('app_users')
    .select('role, is_active')
    .eq('id', data.user.id)
    .maybeSingle();

  return appUser?.role === 'admin' && appUser?.is_active === true;
}

function readBearerToken(request: Request): string | null {
  const header = request.headers.get('Authorization') ?? '';
  const match = header.match(/^Bearer\s+(.+)$/i);
  return match?.[1] ?? null;
}

async function readJsonBody<T>(request: Request): Promise<T | null> {
  try {
    const body = await request.json();
    return body && typeof body === 'object' ? (body as T) : null;
  } catch (_) {
    return null;
  }
}

function failure(message: string) {
  return { success: false, message };
}

function jsonResponse(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}
