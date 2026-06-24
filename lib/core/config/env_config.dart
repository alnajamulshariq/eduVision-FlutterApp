import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class EnvConfig {
  static const _defaultAppEnv = 'development';
  static const _compileTimeSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const _compileTimeSupabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );
  static const _compileTimeAppEnv = String.fromEnvironment('APP_ENV');
  static const _compileTimeUseMockData = String.fromEnvironment(
    'USE_MOCK_DATA',
  );
  static const _compileTimeFaceApiBaseUrl = String.fromEnvironment(
    'FACE_API_BASE_URL',
  );

  static String get supabaseUrl {
    return _readValue(
      'SUPABASE_URL',
      compileTimeValue: _compileTimeSupabaseUrl,
    );
  }

  static String get supabaseAnonKey {
    return _readValue(
      'SUPABASE_ANON_KEY',
      compileTimeValue: _compileTimeSupabaseAnonKey,
    );
  }

  static String get appEnv {
    final value = _readValue('APP_ENV', compileTimeValue: _compileTimeAppEnv);
    return value.isEmpty ? _defaultAppEnv : value;
  }

  static bool get useMockData {
    final value = _readValue(
      'USE_MOCK_DATA',
      compileTimeValue: _compileTimeUseMockData,
    );

    if (value.isEmpty) {
      return true;
    }

    return _isTruthy(value);
  }

  static String get faceApiBaseUrl {
    return _readValue(
      'FACE_API_BASE_URL',
      compileTimeValue: _compileTimeFaceApiBaseUrl,
    );
  }

  static bool get hasSupabaseConfig {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }

  static bool get hasFaceApiConfig => faceApiBaseUrl.isNotEmpty;

  static String _readValue(String key, {String compileTimeValue = ''}) {
    final envValue = dotenv.env[key]?.trim();

    if (envValue != null && envValue.isNotEmpty) {
      return envValue;
    }

    return compileTimeValue.trim();
  }

  static bool _isTruthy(String value) {
    return switch (value.trim().toLowerCase()) {
      'true' || '1' || 'yes' || 'y' || 'on' => true,
      _ => false,
    };
  }
}
