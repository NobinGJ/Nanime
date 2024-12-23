import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';

class UserProfileScreen extends StatelessWidget {
  final String accessToken;

  const UserProfileScreen({Key? key, required this.accessToken}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de Usuario'),
      ),
      body: FutureBuilder<User>(
        future: _fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user.avatarUrl),
                  ),
                  SizedBox(height: 20),
                  Text(
                    user.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('No se encontró información del usuario.'));
          }
        },
      ),
    );
  }

  Future<User> _fetchUserProfile() async {
    final response = await http.get(
      Uri.parse('https://graphql.anilist.co'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final userData = jsonResponse['data']['Viewer'];
      return User(
        name: userData['name'],
        avatarUrl: userData['avatar']['large'],
      );
    } else {
      throw Exception('Error al cargar el perfil del usuario');
    }
  }
}

class User {
  final String name;
  final String avatarUrl;

  User({required this.name, required this.avatarUrl});
}