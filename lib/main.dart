
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth_screen.dart';
import 'home_screen.dart';
import 'appColors.dart';

TextStyle poemTextStyle(
  String language, {
  double fontSize = 16,
  Color color = Appcolors.textColor,
}) {
  if (language == 'Bangla' || language == 'বাংলা') {
    return GoogleFonts.notoSerifBengali(
      fontSize: fontSize,
      height: 1.7,
      color: color,
    );
  } else {
    return GoogleFonts.lora(
      fontSize: fontSize,
      height: 1.5,
      color: color,
    );
  }
}

final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://eaczttzpggbrfzvnjccp.supabase.co',
    anonKey: 'sb_publishable_eBA35mZ7tfr9gMnWpw3a3Q_eGqZKRNq',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Audiyo',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Appcolors.paperColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Appcolors.navyColor,
          brightness: Brightness.light,
        ).copyWith(
          primary: Appcolors.navyColor,
          secondary: Appcolors.burgundyColor,
          tertiary: Appcolors.goldColor,
          surface: Appcolors.cardColor,
        ),
        fontFamily: GoogleFonts.lora().fontFamily,
        appBarTheme: const AppBarTheme(
          backgroundColor: Appcolors.paperColor,
          foregroundColor: Appcolors.navyColor,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Appcolors.cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelStyle: const TextStyle(color: Appcolors.textColor),
          prefixIconColor: Appcolors.navyColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Appcolors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Appcolors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Appcolors.navyColor,
              width: 1.5,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: Appcolors.navyColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session =
            snapshot.data?.session ?? supabase.auth.currentSession;

        if (session != null) {
          return const HomeScreen();
        }

        return const AuthScreen();
      },
    );
  }
}
