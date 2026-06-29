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

  const actorUserId = await verifyAdminCaller(request, admin);
  if (!actorUserId) {
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

  const { error: profileError } = await admin
    .from('app_users')
    .update({ is_first_login: true, password_changed_once: false })
    .eq('id', userId);

  if (profileError) {
    return jsonResponse(
      failure(
        'Temporary password was set, but user profile flags could not be updated.',
      ),
      200,
    );
  }

  await logActivity(admin, {
    actorUserId,
    action: 'password_reset',
    targetType: 'user',
    targetId: userId,
    description: 'Temporary password reset successfully.',
  });

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

function createCallerClient(token: string) {
  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY');

  if (!supabaseUrl || !anonKey) {
    return null;
  }

  return createClient(supabaseUrl, anonKey, {
    auth: { persistSession: false },
    global: { headers: { Authorization: `Bearer ${token}` } },
  });
}

async function verifyAdminCaller(
  request: Request,
  admin: ReturnType<typeof createClient>,
): Promise<string | null> {
  const token = readBearerToken(request);
  if (!token) {
    return null;
  }

  const { data, error } = await admin.auth.getUser(token);
  if (error || !data.user) {
    return null;
  }

  const caller = createCallerClient(token);
  if (!caller) {
    return null;
  }

  const { data: appUser, error: appUserError } = await caller
    .from('app_users')
    .select('role, is_active')
    .eq('id', data.user.id)
    .maybeSingle();

  if (appUserError || !appUser) {
    return null;
  }

  return appUser?.role === 'admin' && appUser?.is_active === true
    ? data.user.id
    : null;
}

async function logActivity(
  admin: ReturnType<typeof createClient>,
  event: {
    actorUserId: string;
    action: string;
    targetType?: string;
    targetId?: string;
    description?: string;
    metadata?: Record<string, unknown>;
  },
): Promise<void> {
  try {
    await admin.from('system_activity_logs').insert({
      actor_user_id: event.actorUserId,
      action: event.action,
      target_type: event.targetType ?? null,
      target_id: event.targetId ?? null,
      description: event.description ?? null,
      metadata: event.metadata ?? null,
    });
  } catch (_) {
    // Audit logging must never block the password reset result.
  }
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
