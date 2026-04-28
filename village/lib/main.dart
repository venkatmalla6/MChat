import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'main_layout.dart';
import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'screens/admin/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://jlufpinayacuilmldhmy.supabase.co',
    anonKey: 'sb_publishable_1gpMoKbtSv9EvohRr4wGCQ_g0foOOoZ',
  );

  // Initialize Firebase for Web
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAaQMe0RJNU_WA_mhFuppXX5-Igsq1YrRg",
      authDomain: "village-75.firebaseapp.com",
      databaseURL: "https://village-75-default-rtdb.firebaseio.com",
      projectId: "village-75",
      storageBucket: "village-75.firebasestorage.app",
      messagingSenderId: "10633609131",
      appId: "1:10633609131:web:c161974d7200dd524fdcee",
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: const SomarayanampetaApp(),
    ),
  );
}

class SomarayanampetaApp extends StatelessWidget {
  const SomarayanampetaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Somarayanampeta Village',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D5A27),
          primary: const Color(0xFF2D5A27),
          secondary: const Color(0xFF1B3D16),
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
          ),
          displayMedium: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainLayout(),
        '/admin/login': (context) => const AdminLoginScreen(), 
        '/admin/dashboard': (context) => const AdminDashboard(),
      },
    );
  }
}
