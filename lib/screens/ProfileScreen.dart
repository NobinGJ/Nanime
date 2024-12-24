import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserProfileScreen extends StatelessWidget {
  final String accessToken;

  const UserProfileScreen({Key? key, required this.accessToken}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Usuario')),
      body: FutureBuilder(
        future: _fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final profile = snapshot.data as Map<String, dynamic>;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(profile['avatar']['large']),
                const SizedBox(height: 20),
                Text(
                  profile['name'],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchUserProfile() async {
    final response = await http.post(
      Uri.parse('https://graphql.anilist.co'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'query': '''
          query {
            Viewer {
              id
              name
              avatar {
                large
              }
            }
          }
        ''',
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['Viewer'];
    } else {
      throw Exception('Failed to load profile');
    }
  }
}