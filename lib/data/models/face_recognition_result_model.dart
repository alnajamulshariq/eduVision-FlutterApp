class FaceRecognitionStudentCandidateModel {
  const FaceRecognitionStudentCandidateModel({
    required this.studentId,
    this.studentName,
    this.rollNo,
  });

  final String studentId;
  final String? studentName;
  final String? rollNo;
}

class FaceRecognitionAttendanceResultModel {
  const FaceRecognitionAttendanceResultModel({
    required this.studentId,
    required this.framesDetected,
    required this.totalFrames,
    required this.attendancePercentage,
    required this.attendanceStatus,
    this.studentName,
    this.rollNo,
    this.confidence,
    this.message,
    this.recognitionMethod = 'face_recognition',
  });

  final String studentId;
  final String? studentName;
  final String? rollNo;
  final int framesDetected;
  final int totalFrames;
  final double attendancePercentage;
  final String attendanceStatus;
  final double? confidence;
  final String? message;
  final String recognitionMethod;

  factory FaceRecognitionAttendanceResultModel.fromJson(
    Map<String, dynamic> json, {
    required int fallbackTotalFrames,
  }) {
    final totalFrames =
        _readInt(json['totalFrames'] ?? json['total_frames']) ??
        fallbackTotalFrames;
    final framesDetected =
        _readInt(json['framesDetected'] ?? json['frames_detected']) ?? 0;
    final percentage =
        _readDouble(
          json['attendancePercentage'] ?? json['attendance_percentage'],
        ) ??
        _percentage(framesDetected, totalFrames);

    return FaceRecognitionAttendanceResultModel(
      studentId: (json['studentId'] ?? json['student_id'] ?? '')
          .toString()
          .trim(),
      studentName: _readText(json['studentName'] ?? json['student_name']),
      rollNo: _readText(json['rollNo'] ?? json['roll_no']),
      framesDetected: framesDetected,
      totalFrames: totalFrames,
      attendancePercentage: percentage,
      attendanceStatus: _normalizeStatus(
        json['attendanceStatus'] ?? json['attendance_status'],
        percentage,
      ),
      confidence: _readDouble(json['confidence']),
      message: _readText(json['message']),
      recognitionMethod:
          _readText(json['recognitionMethod'] ?? json['recognition_method']) ??
          'face_recognition',
    );
  }

  FaceRecognitionAttendanceResultModel copyWith({
    String? studentId,
    String? studentName,
    String? rollNo,
    int? framesDetected,
    int? totalFrames,
    double? attendancePercentage,
    String? attendanceStatus,
    double? confidence,
    String? message,
    String? recognitionMethod,
  }) {
    return FaceRecognitionAttendanceResultModel(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      rollNo: rollNo ?? this.rollNo,
      framesDetected: framesDetected ?? this.framesDetected,
      totalFrames: totalFrames ?? this.totalFrames,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      confidence: confidence ?? this.confidence,
      message: message ?? this.message,
      recognitionMethod: recognitionMethod ?? this.recognitionMethod,
    );
  }

  static double _percentage(int framesDetected, int totalFrames) {
    if (totalFrames <= 0) {
      return 0;
    }

    return ((framesDetected / totalFrames) * 100).clamp(0, 100).toDouble();
  }

  static String _normalizeStatus(dynamic value, double percentage) {
    final normalized = value?.toString().trim().toLowerCase();

    if (normalized == 'present' || normalized == 'absent') {
      return normalized!;
    }

    return percentage >= 75 ? 'present' : 'absent';
  }

  static String? _readText(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  static int? _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString().trim() ?? '');
  }

  static double? _readDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString().trim() ?? '');
  }
}

class FaceRecognitionSessionResultModel {
  const FaceRecognitionSessionResultModel({
    required this.results,
    required this.totalFrames,
    required this.usedFallback,
    required this.message,
    this.status = 'completed',
  });

  final List<FaceRecognitionAttendanceResultModel> results;
  final int totalFrames;
  final bool usedFallback;
  final String message;
  final String status;

  int get totalStudents => results.length;

  int get recognizedStudents {
    return results.where((result) => result.framesDetected > 0).length;
  }

  int get presentCount {
    return results
        .where((result) => result.attendanceStatus.toLowerCase() == 'present')
        .length;
  }

  int get absentCount {
    return results
        .where((result) => result.attendanceStatus.toLowerCase() == 'absent')
        .length;
  }

  factory FaceRecognitionSessionResultModel.fromJson(
    Map<String, dynamic> json, {
    required int fallbackTotalFrames,
  }) {
    final rawResults = _readResults(json);
    final totalFrames =
        FaceRecognitionAttendanceResultModel._readInt(
          json['totalFrames'] ?? json['total_frames'],
        ) ??
        fallbackTotalFrames;

    return FaceRecognitionSessionResultModel(
      results: rawResults
          .map(
            (item) => FaceRecognitionAttendanceResultModel.fromJson(
              item,
              fallbackTotalFrames: totalFrames,
            ),
          )
          .where((result) => result.studentId.isNotEmpty)
          .toList(),
      totalFrames: totalFrames,
      usedFallback:
          json['usedFallback'] == true || json['used_fallback'] == true,
      message:
          FaceRecognitionAttendanceResultModel._readText(json['message']) ??
          'Face recognition processing completed.',
      status:
          FaceRecognitionAttendanceResultModel._readText(json['status']) ??
          'completed',
    );
  }

  FaceRecognitionSessionResultModel copyWith({
    List<FaceRecognitionAttendanceResultModel>? results,
    int? totalFrames,
    bool? usedFallback,
    String? message,
    String? status,
  }) {
    return FaceRecognitionSessionResultModel(
      results: results ?? this.results,
      totalFrames: totalFrames ?? this.totalFrames,
      usedFallback: usedFallback ?? this.usedFallback,
      message: message ?? this.message,
      status: status ?? this.status,
    );
  }

  static List<Map<String, dynamic>> _readResults(Map<String, dynamic> json) {
    final raw = json['results'] ?? json['students'] ?? json['records'];

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    final data = json['data'];

    if (data is Map) {
      return _readResults(Map<String, dynamic>.from(data));
    }

    return const [];
  }
}
