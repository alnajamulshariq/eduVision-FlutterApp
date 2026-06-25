import 'package:eduvision_app/app/app.dart';
import 'package:eduvision_app/app/theme_controller.dart';
import 'package:eduvision_app/data/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Missing .env is expected while EduVision runs in frontend mock mode.
  }

  await const SupabaseService().initialize();

  final preferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const EduVisionApp(),
    ),
  );
}
