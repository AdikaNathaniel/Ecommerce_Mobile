import 'package:flutter/material.dart';

class PurchasesPage extends StatelessWidget {
  final String userEmail;

  PurchasesPage({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchases'),
      ),
      body: Center(
        child: Text('This is the Purchases Page.'),
      ),
    );
  }
}