abstract final class EnvConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const faceApiBaseUrl = String.fromEnvironment('FACE_API_BASE_URL');

  static bool get hasSupabaseConfig {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }

  static bool get hasFaceApiConfig => faceApiBaseUrl.isNotEmpty;
}
