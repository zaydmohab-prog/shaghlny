import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print("✅ Firebase initialized successfully");
  } catch (e, stack) {
    print("🔥 FIREBASE INIT ERROR:");
    print(e);
    print(stack);
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text("Firebase initialization failed"),
          ),
        ),
      ),
    );
    return;
  }

  runApp(const ShaghlnyApp());
}
class ShaghlnyApp extends StatelessWidget {
  const ShaghlnyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "SHAGHLNY",
        theme: ThemeData(
          primaryColor: const Color(0xFF2196F3),
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class FirebaseErrorApp extends StatelessWidget {
  const FirebaseErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            "Firebase connection failed",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
