import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gqslfxawzluzmvgiuyym.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdxc2xmeGF3emx1em12Z2l1eXltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA2ODQ2NDUsImV4cCI6MjA2NjI2MDY0NX0.nl2Z9CIEmJ1zhV2Au4zVpw12hlyzmgxi-WI10sEAv5E',
  );
  runApp(const SkillKartApp());
}

class SkillKartApp extends StatelessWidget {
  const SkillKartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillKart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      routes: {
    
    '/login': (context) => LoginScreen(),
  },
      home: const SplashScreen(),
    );
  }
}
