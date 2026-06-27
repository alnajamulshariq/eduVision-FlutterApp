abstract final class AppConstants {
  static const appName = 'EduVision';
  static const appTagline = 'Smart University Attendance & Monitoring';
  static const companyName = 'Zentherix';
  static const companyWebsite = 'https://www.zentherix.com/';
  static const companyEmail = 'info@zentherix.com';
  static const aboutTitle = 'About EduVision';
  static const aboutDescription =
      'EduVision is a smart university attendance and monitoring system '
      'designed to improve attendance accuracy, campus security, and '
      'communication between students and teachers.';
  static const companyDescription =
      'Zentherix is a software development company focused on building modern '
      'web, mobile, and AI-powered digital solutions.';
  static const modules = [
    'Smart Attendance',
    'Gate Entry & Exit Monitoring',
    'Anonymous Messaging',
    'Role-Based Dashboards',
  ];
}

abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const student = '/student';
  static const studentQr = '/student/qr';
  static const studentAttendance = '/student/attendance';
  static const studentGateHistory = '/student/gate-history';
  static const studentAnonymousMessage = '/student/anonymous-message';
  static const teacher = '/teacher';
  static const teacherTimetable = '/teacher/timetable';
  static const teacherStartAttendance = '/teacher/start-attendance';
  static const teacherAttendanceReports = '/teacher/attendance-reports';
  static const teacherQrScanner = '/teacher/qr-scanner';
  static const teacherAnonymousMessages = '/teacher/anonymous-messages';
  static const teacherGateMonitoring = '/teacher/gate-monitoring';
  static const admin = '/admin';
  static const adminUsers = '/admin/users';
  static const adminAcademics = '/admin/academics';
  static const adminAttendanceReports = '/admin/attendance-reports';
  static const adminGateLogs = '/admin/gate-logs';
  static const adminMessageReports = '/admin/message-reports';

  static String dashboardForRole(String role) {
    return switch (role.toLowerCase()) {
      'student' => student,
      'teacher' => teacher,
      'admin' => admin,
      _ => login,
    };
  }
}
