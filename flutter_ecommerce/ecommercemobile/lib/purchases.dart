import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart'; // Import your LoginPage
import 'product.dart'; // Your Product model

class PurchasesPage extends StatelessWidget {
  final List<dynamic> orders; // List of orders
  final String userEmail;

  const PurchasesPage({required this.orders, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Center(
          child: Text(
            'My Purchases',
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              child: Text(
                userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'U',
                style: TextStyle(color: Colors.blue),
              ),
              backgroundColor: Colors.white,
            ),
            onPressed: () => _showUserInfoDialog(context), // Show user info dialog
          ),
        ],
      ),
      body: Container(
        color: Colors.blue[50],
        child: orders.isEmpty
            ? Center(
                child: Text(
                  'No purchases found!',
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
              )
            : ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        order['productName'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Quantity: ${order['quantity']}'),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Icon(Icons.check_circle, color: Colors.green, size: 50),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showUserInfoDialog(BuildContext context) {
    String email = userEmail; 
    String role = 'Customer'; // Hardcoded role

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(child: Text('Account Details')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email),
                SizedBox(width: 10),
                Text(email),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person),
                SizedBox(width: 10),
                Text(role),
              ],
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                // Call logout API
                final response = await http.put(
                  Uri.parse('http://localhost:3100/api/v1/users/logout'),
                  headers: {'Content-Type': 'application/json'},
                );

                if (response.statusCode == 200) {
                  final responseData = json.decode(response.body);
                  if (responseData['success']) {
                    _showSuccessDialog(context, "Logout successfully");
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  } else {
                    _showSnackbar(context, "Logout failed: ${responseData['message']}", Colors.red);
                  }
                } else {
                  _showSnackbar(context, "Logout failed: Server error", Colors.red);
                }
              },
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}