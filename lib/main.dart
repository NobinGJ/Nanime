import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/ProfileScreen.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nanime',
      theme: ThemeData.dark(),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await _readTokenFromFile();

    if (token != null) {
      // Verificar si el token es válido
      final isValid = await _verifyToken(token);
      if (isValid) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(accessToken: token),
          ),
        );
        return;
      }
    }

    // Si no hay token válido, ir al login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<bool> _verifyToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://graphql.anilist.co'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String?> _readTokenFromFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/token.txt');
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}