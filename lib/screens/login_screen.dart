import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'ProfileScreen.dart';

class LoginScreen extends StatelessWidget {
  final String clientId = '22702'; // Replace with your client_id
  final String clientSecret = 'DjcS5pzDXOKyuxrBGBmDfAtyJqnOU61gFnJrsNlJ'; // Replace with your client_secret
  final String redirectUri = 'http://localhost:8080'; // Replace with your redirect_uri

  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(), // Animated background
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/logos/logo.png', // Change to your logo path
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Inicia sesión con tu cuenta de AniList',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => _loginWithAniList(context),
                  icon: const Icon(Icons.login),
                  label: const Text('Login con AniList'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loginWithAniList(BuildContext context) async {
    final authUrl = Uri.parse(
        'https://anilist.co/api/v2/oauth/authorize?client_id=$clientId&response_type=code&redirect_uri=$redirectUri');

    if (await canLaunch(authUrl.toString())) {
      await launch(authUrl.toString());
    } else {
      _showError(context, 'Could not launch the browser for login.');
    }

    // Start a local server to listen for the redirect
    final code = await _listenForCode();
    if (code != null) {
      // Exchange the code for an access token
      final tokenResponse = await http.post(
        Uri.parse('https://anilist.co/api/v2/oauth/token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'grant_type': 'authorization_code',
          'client_id': clientId,
          'client_secret': clientSecret,
          'redirect_uri': redirectUri,
          'code': code,
        }),
      );

      if (tokenResponse.statusCode == 200) {
        final tokenData = json.decode(tokenResponse.body);
        final accessToken = tokenData['access_token'];

        // Save the token locally
        await _saveTokenToFile(accessToken);

        // Navigate to the profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(accessToken: accessToken),
          ),
        );
      } else {
        _showError(context, 'Error al obtener el token.');
      }
    } else {
      _showError(context, 'Error al iniciar sesión.');
    }
  }

  Future<void> _saveTokenToFile(String token) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/token.txt');
      await file.writeAsString(token);
    } catch (e) {
      // Handle error
    }
  }

  Future<String?> _listenForCode() async {
    final completer = Completer<String?>();
    final handler = (shelf.Request request) {
      final code = request.url.queryParameters['code'];
      completer.complete(code);
      return shelf.Response.ok('You can close this window now.');
    };

    final server = await shelf_io.serve(handler, 'localhost', 8080);
    final code = await completer.future;
    await server.close();
    return code;
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class AnimatedBackground extends StatefulWidget {
  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.red.withOpacity(0.5), Colors.black],
              stops: [
                0.0,
                (_controller.value / 2).clamp(0.0, 1.0),
                1.0,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}