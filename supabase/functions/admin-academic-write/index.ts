import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

type AcademicWriteBody = {
  operation?: string;
  payload?: Record<string, unknown>;
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

  const body = await readJsonBody<AcademicWriteBody>(request);
  const operation = body?.operation?.trim();
  const payload = body?.payload ?? {};

  if (!operation) {
    return jsonResponse(failure('Academic operation is required.'), 400);
  }

  const result = await runOperation(admin, operation, payload);
  if (result.success === true) {
    await logActivity(admin, {
      actorUserId,
      ...auditEventForOperation(operation, `${result.recordId ?? ''}`),
    });
  }

  return jsonResponse(result);
});

async function runOperation(
  admin: ReturnType<typeof createClient>,
  operation: string,
  payload: Record<string, unknown>,
): Promise<Record<string, unknown>> {
  if (operation === 'create_department') {
    const name = readText(payload.name);
    const code = readText(payload.code)?.toUpperCase();

    if (!name || !code) {
      return failure('Department name and code are required.');
    }

    const { data, error } = await admin
      .from('departments')
      .insert({ name, code })
      .select('id')
      .single();

    return writeResult(error, data?.id, 'Department created successfully.');
  }

  if (operation === 'create_subject') {
    const name = readText(payload.name);
    const code = readText(payload.code)?.toUpperCase();
    const departmentId = readText(payload.departmentId);
    const semesterId = readText(payload.semesterId);

    if (!name || !code || !departmentId || !semesterId) {
      return failure('Subject name, code, department, and semester are required.');
    }

    const { data, error } = await admin
      .from('subjects')
      .insert({
        name,
        code,
        department_id: departmentId,
        semester_id: semesterId,
      })
      .select('id')
      .single();

    return writeResult(error, data?.id, 'Subject created successfully.');
  }

  if (operation === 'create_batch') {
    const name = readText(payload.name);
    const year = readInteger(payload.year);
    const departmentId = readText(payload.departmentId);

    if (!name || !year || !departmentId) {
      return failure('Batch name, year, and department are required.');
    }

    const { data, error } = await admin
      .from('batches')
      .insert({ name, year, department_id: departmentId })
      .select('id')
      .single();

    return writeResult(error, data?.id, 'Batch created successfully.');
  }

  if (operation === 'create_semester') {
    const name = readText(payload.name);
    const number = readInteger(payload.number);

    if (!name || !number) {
      return failure('Semester name and number are required.');
    }

    const { data, error } = await admin
      .from('semesters')
      .insert({ name, number })
      .select('id')
      .single();

    return writeResult(error, data?.id, 'Semester created successfully.');
  }

  if (operation === 'assign_teacher') {
    const teacherId = readText(payload.teacherId);
    const subjectId = readText(payload.subjectId);
    const departmentId = readText(payload.departmentId);
    const batchId = readText(payload.batchId);
    const semesterId = readText(payload.semesterId);

    if (!teacherId || !subjectId || !departmentId || !batchId || !semesterId) {
      return failure('Teacher, subject, department, batch, and semester are required.');
    }

    const { data, error } = await admin
      .from('teacher_subjects')
      .upsert(
        {
          teacher_id: teacherId,
          subject_id: subjectId,
          department_id: departmentId,
          batch_id: batchId,
          semester_id: semesterId,
          is_active: true,
        },
        {
          onConflict:
            'teacher_id,subject_id,department_id,batch_id,semester_id',
        },
      )
      .select('id')
      .single();

    return writeResult(error, data?.id, 'Teacher assigned successfully.');
  }

  if (operation === 'enroll_student') {
    const studentId = readText(payload.studentId);
    const subjectId = readText(payload.subjectId);
    const departmentId = readText(payload.departmentId);
    const batchId = readText(payload.batchId);
    const semesterId = readText(payload.semesterId);

    if (!studentId || !subjectId || !departmentId || !batchId || !semesterId) {
      return failure('Student, subject, department, batch, and semester are required.');
    }

    const { data, error } = await admin
      .from('student_subjects')
      .upsert(
        {
          student_id: studentId,
          subject_id: subjectId,
          department_id: departmentId,
          batch_id: batchId,
          semester_id: semesterId,
          is_active: true,
        },
        {
          onConflict:
            'student_id,subject_id,department_id,batch_id,semester_id',
        },
      )
      .select('id')
      .single();

    return writeResult(error, data?.id, 'Student enrolled successfully.');
  }

  return failure('Unsupported academic operation.');
}

function auditEventForOperation(
  operation: string,
  recordId: string,
): {
  action: string;
  targetType: string;
  targetId: string | null;
  description: string;
  metadata: Record<string, unknown>;
} {
  const targetId = recordId.trim() || null;

  if (operation === 'create_department') {
    return {
      action: 'department_created',
      targetType: 'department',
      targetId,
      description: 'Department created successfully.',
      metadata: { operation },
    };
  }

  if (operation === 'create_batch') {
    return {
      action: 'batch_created',
      targetType: 'batch',
      targetId,
      description: 'Batch created successfully.',
      metadata: { operation },
    };
  }

  if (operation === 'create_semester') {
    return {
      action: 'semester_created',
      targetType: 'semester',
      targetId,
      description: 'Semester created successfully.',
      metadata: { operation },
    };
  }

  if (operation === 'create_subject') {
    return {
      action: 'subject_created',
      targetType: 'subject',
      targetId,
      description: 'Subject created successfully.',
      metadata: { operation },
    };
  }

  if (operation === 'assign_teacher') {
    return {
      action: 'teacher_assigned',
      targetType: 'teacher_subject',
      targetId,
      description: 'Teacher assigned successfully.',
      metadata: { operation },
    };
  }

  if (operation === 'enroll_student') {
    return {
      action: 'student_enrolled',
      targetType: 'student_subject',
      targetId,
      description: 'Student enrolled successfully.',
      metadata: { operation },
    };
  }

  return {
    action: 'academic_write_completed',
    targetType: 'academic_record',
    targetId,
    description: 'Academic write completed successfully.',
    metadata: { operation },
  };
}

function writeResult(
  error: unknown,
  recordId: string | undefined,
  message: string,
): Record<string, unknown> {
  if (error) {
    return failure('Academic write could not be completed.');
  }

  return { success: true, recordId, message };
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
    targetId?: string | null;
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
    // Audit logging must never block academic write results.
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

function readText(value: unknown): string | null {
  const text = `${value ?? ''}`.trim();
  return text.isEmpty ? null : text;
}

function readInteger(value: unknown): number | null {
  const parsed = Number.parseInt(`${value ?? ''}`, 10);
  return Number.isFinite(parsed) ? parsed : null;
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
