import 'package:flutter/material.dart';

class TopChartsPage extends StatelessWidget {
  final String userEmail;

  TopChartsPage({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top Charts'),
      ),
      body: Center(
        child: Text('This is the Top Charts Page.'),
      ),
    );
  }
}