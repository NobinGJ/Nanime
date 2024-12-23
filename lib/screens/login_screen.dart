import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'ProfileScreen.dart';

class LoginScreen extends StatelessWidget {
  final String clientId = '22702'; // Reemplaza con tu client_id de AniList
  final String redirectUri = 'http://localhost:8080'; // Reemplaza con tu redirect_uri

  const LoginScreen({super.key});

  get authUrl => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de la app
            Image.asset(
              'assets/logos/logo.png', // Coloca tu logo en la carpeta assets
              width: 150,
              height: 150,
            ),
            SizedBox(height: 20),
            Text(
              'Inicia sesión con tu cuenta de AniList',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                _loginWithAniList(context);
              },
              icon: Icon(Icons.login),
              label: Text('Login con AniList'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Color del botón
                foregroundColor: Colors.white, // Color del texto
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _loginWithAniList(BuildContext context) async {
    final authUrl = Uri.parse(
        'https://anilist.co/api/v2/oauth/authorize?client_id=$clientId&response_type=code&redirect_uri=$redirectUri');

    if (await canLaunchUrl(authUrl)) {
      await launchUrl(authUrl);

      // Aquí deberías manejar el redireccionamiento y obtener el código
      // Por simplicidad, asumimos que el código se obtiene de alguna manera
      String? code = await _getAuthorizationCode(context); // Implementa esta función según tu lógica

      if (code != null) {
        // Intercambiar el código por un token de acceso
        final tokenResponse = await http.post(
          Uri.parse('https://anilist.co/api/v2/oauth/token'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'grant_type': 'authorization_code',
            'client_id': clientId,
            'client_secret': 'DjcS5pzDXOKyuxrBGBmDfAtyJqnOU61gFnJrsNlJ', // Reemplaza con tu client_secret
            'redirect_uri': redirectUri,
            'code': code,
          }),
        );

        if (tokenResponse.statusCode == 200) {
          final tokenData = json.decode(tokenResponse.body);
          final accessToken = tokenData['access_token'];

          // Navegar a la pantalla de perfil de usuario
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileScreen(accessToken: accessToken),
            ),
          );
        } else {
          throw Exception('Error al obtener el token de acceso');
        }
      }
    } else {
      throw 'No se pudo abrir el navegador';
    }
  }

  Future<String?> _getAuthorizationCode(BuildContext context) async {
    final flutterWebviewPlugin = FlutterWebviewPlugin();
    final codeCompleter = Completer<String?>();

    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (url.startsWith(redirectUri)) {
        final uri = Uri.parse(url);
        final code = uri.queryParameters['code'];
        flutterWebviewPlugin.close();
        codeCompleter.complete(code);

        // Mostrar mensaje de que puede cerrar la pestaña
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Código obtenido. Puede cerrar la pestaña del navegador.')),
        );
      }
    });

    flutterWebviewPlugin.launch(authUrl.toString());
    return codeCompleter.future;
  }
}