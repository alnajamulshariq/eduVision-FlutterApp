import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

type CreateUserBody = {
  name?: string;
  universityEmail?: string;
  role?: string;
  temporaryPassword?: string;
  rollNo?: string;
  employeeId?: string;
  departmentId?: string;
  batchId?: string;
  semesterId?: string;
  parentEmail?: string;
};

type VerifyAdminCallerResult = {
  userId: string | null;
  reason?:
    | 'missing_bearer_token'
    | 'auth_get_user_failed'
    | 'app_user_not_found'
    | 'not_admin_or_inactive';
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

  const actor = await verifyAdminCaller(request, admin);
  if (!actor.userId) {
    return jsonResponse(
      failure(
        `Only admins can perform this action. Reason: ${
          actor.reason ?? 'unknown'
        }`,
      ),
      403,
    );
  }

  const body = await readJsonBody<CreateUserBody>(request);
  const validation = validateCreateUserBody(body);
  if (validation) {
    return jsonResponse(failure(validation), 400);
  }

  const role = body!.role!.trim().toLowerCase();
  const email = body!.universityEmail!.trim().toLowerCase();
  const name = body!.name!.trim();

  const { data: authUser, error: authError } = await admin.auth.admin
    .createUser({
      email,
      password: body!.temporaryPassword!,
      email_confirm: true,
      user_metadata: { name, role },
    });

  if (authError || !authUser.user) {
    return jsonResponse(
      failure('Unable to create Auth user. The email may already exist.'),
      200,
    );
  }

  const userId = authUser.user.id;
  const { error: appUserError } = await admin.from('app_users').insert({
    id: userId,
    name,
    university_email: email,
    role,
    is_first_login: true,
    password_changed_once: false,
    is_active: true,
  });

  if (appUserError) {
    await admin.auth.admin.deleteUser(userId);
    return jsonResponse(failure('Unable to create app user profile.'), 200);
  }

  const profileError = await createRoleProfile(admin, userId, role, body!);
  if (profileError) {
    await admin.auth.admin.deleteUser(userId);
    return jsonResponse(failure(profileError), 200);
  }

  await logActivity(admin, {
    actorUserId: actor.userId,
    action: 'user_created',
    targetType: role,
    targetId: userId,
    description: `${titleCase(role)} account created successfully.`,
    metadata: { role },
  });

  return jsonResponse({
    success: true,
    createdUserId: userId,
    message: `${titleCase(role)} account created successfully.`,
  });
});

async function createRoleProfile(
  admin: ReturnType<typeof createClient>,
  userId: string,
  role: string,
  body: CreateUserBody,
): Promise<string | null> {
  if (role === 'student') {
    const { error } = await admin.from('students').insert({
      user_id: userId,
      roll_no: body.rollNo!.trim(),
      name: body.name!.trim(),
      department_id: body.departmentId!.trim(),
      batch_id: body.batchId!.trim(),
      semester_id: body.semesterId!.trim(),
      parent_email: body.parentEmail?.trim() || null,
      is_active: true,
    });

    return error ? 'Unable to create student profile.' : null;
  }

  if (role === 'teacher') {
    const { error } = await admin.from('teachers').insert({
      user_id: userId,
      employee_id: body.employeeId!.trim(),
      name: body.name!.trim(),
      department_id: body.departmentId!.trim(),
      is_active: true,
    });

    return error ? 'Unable to create teacher profile.' : null;
  }

  return null;
}

function validateCreateUserBody(body: CreateUserBody | null): string | null {
  if (!body) {
    return 'Invalid request payload.';
  }

  const role = body.role?.trim().toLowerCase();
  const password = body.temporaryPassword ?? '';

  if (!body.name?.trim() || !body.universityEmail?.trim() || !role) {
    return 'Name, university email, and role are required.';
  }

  if (!['student', 'teacher', 'admin'].includes(role)) {
    return 'Role must be student, teacher, or admin.';
  }

  if (password.length < 6) {
    return 'Temporary password must be at least 6 characters.';
  }

  if (role === 'student') {
    if (
      !body.rollNo?.trim() ||
      !body.departmentId?.trim() ||
      !body.batchId?.trim() ||
      !body.semesterId?.trim()
    ) {
      return 'Student roll number, department, batch, and semester are required.';
    }
  }

  if (role === 'teacher') {
    if (!body.employeeId?.trim() || !body.departmentId?.trim()) {
      return 'Teacher employee ID and department are required.';
    }
  }

  return null;
}

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
): Promise<VerifyAdminCallerResult> {
  const token = readBearerToken(request);
  if (!token) {
    return { userId: null, reason: 'missing_bearer_token' };
  }

  const { data, error } = await admin.auth.getUser(token);
  if (error || !data.user) {
    return { userId: null, reason: 'auth_get_user_failed' };
  }

  const caller = createCallerClient(token);
  if (!caller) {
    return { userId: null, reason: 'app_user_not_found' };
  }

  const { data: appUser, error: appUserError } = await caller
    .from('app_users')
    .select('role, is_active')
    .eq('id', data.user.id)
    .maybeSingle();

  if (appUserError || !appUser) {
    return { userId: null, reason: 'app_user_not_found' };
  }

  if (appUser.role !== 'admin' || appUser.is_active !== true) {
    return { userId: null, reason: 'not_admin_or_inactive' };
  }

  return { userId: data.user.id };
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
  await admin.from('system_activity_logs').insert({
    actor_user_id: event.actorUserId,
    action: event.action,
    target_type: event.targetType ?? null,
    target_id: event.targetId ?? null,
    description: event.description ?? null,
    metadata: event.metadata ?? null,
  });
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

function titleCase(value: string): string {
  return `${value.charAt(0).toUpperCase()}${value.slice(1)}`;
}

function jsonResponse(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}
