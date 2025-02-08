import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  final String userEmail;

  FavoritesPage({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: Center(
        child: Text('This is the Favorites Page.'),
      ),
    );
  }
}