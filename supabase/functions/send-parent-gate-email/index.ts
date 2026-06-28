import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

type JsonBody = {
  gateLogId?: string;
  studentId?: string;
};

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') {
    return jsonResponse({ success: true, emailSent: false }, 200);
  }

  if (request.method !== 'POST') {
    return jsonResponse(
      {
        success: false,
        emailSent: false,
        status: 'invalid_request',
        message: 'Only POST requests are supported.',
      },
      405,
    );
  }

  const body = await readJsonBody(request);
  const gateLogId = body?.gateLogId?.trim();
  const studentId = body?.studentId?.trim();

  if (!gateLogId || !studentId) {
    return jsonResponse(
      {
        success: false,
        emailSent: false,
        status: 'invalid_request',
        message: 'Gate log and student identifiers are required.',
      },
      400,
    );
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

  if (!supabaseUrl || !serviceRoleKey) {
    return jsonResponse(
      {
        success: false,
        emailSent: false,
        status: 'server_not_configured',
        message: 'Parent email service is not configured.',
      },
      500,
    );
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false },
  });

  const { data: gateLog, error: gateLogError } = await supabase
    .from('gate_logs')
    .select('id, student_id, log_date, log_time, status, gate_location')
    .eq('id', gateLogId)
    .maybeSingle();

  if (gateLogError || !gateLog || gateLog.student_id !== studentId) {
    return jsonResponse(
      {
        success: false,
        emailSent: false,
        status: 'gate_log_not_found',
        message: 'Gate log could not be verified.',
      },
      404,
    );
  }

  const { data: student, error: studentError } = await supabase
    .from('students')
    .select('id, name, parent_email')
    .eq('id', studentId)
    .maybeSingle();

  if (studentError || !student) {
    return jsonResponse(
      {
        success: false,
        emailSent: false,
        status: 'student_not_found',
        message: 'Student profile could not be verified.',
      },
      404,
    );
  }

  const parentEmail = `${student.parent_email ?? ''}`.trim();

  if (!parentEmail) {
    return jsonResponse(
      {
        success: true,
        emailSent: false,
        status: 'parent_email_missing',
        message: 'Parent email not available.',
      },
      200,
    );
  }

  const resendApiKey = Deno.env.get('RESEND_API_KEY');
  const fromAddress = Deno.env.get('PARENT_EMAIL_FROM');

  if (!resendApiKey || !fromAddress) {
    return jsonResponse(
      {
        success: true,
        emailSent: false,
        status: 'provider_not_configured',
        message: 'Email provider not configured.',
      },
      200,
    );
  }

  const action = gateLog.status === 'entry' ? 'entered' : 'exited';
  const subject =
    gateLog.status === 'entry'
      ? 'EduVision Gate Entry Alert'
      : 'EduVision Gate Exit Alert';
  const text =
    `Student ${student.name} ${action} the university at ${gateLog.log_time} ` +
    `on ${gateLog.log_date} via ${gateLog.gate_location}.\n\n` +
    'This is an automated EduVision notification.';

  const emailResponse = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${resendApiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: fromAddress,
      to: [parentEmail],
      subject,
      text,
    }),
  });

  if (!emailResponse.ok) {
    return jsonResponse(
      {
        success: true,
        emailSent: false,
        status: 'failed',
        message: 'Parent email failed, but the gate log was saved.',
      },
      200,
    );
  }

  await supabase
    .from('gate_logs')
    .update({ parent_email_sent: true })
    .eq('id', gateLogId);

  return jsonResponse(
    {
      success: true,
      emailSent: true,
      status: 'sent',
      message: 'Parent email notification sent.',
    },
    200,
  );
});

async function readJsonBody(request: Request): Promise<JsonBody | null> {
  try {
    const body = await request.json();
    return body && typeof body === 'object' ? (body as JsonBody) : null;
  } catch (_) {
    return null;
  }
}

function jsonResponse(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });
}
