import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart'; // Import your LoginPage
import 'payment_screen.dart'; // Import PaymentScreen
import 'purchases.dart'; // Import PurchasesPage

class OrdersPage extends StatelessWidget {
  final List<dynamic> orders;
  final String userEmail;

  OrdersPage({Key? key, required this.orders, required this.userEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Container(
          width: double.infinity,
          child: Center(
            child: Text(
              'My Orders',
              style: TextStyle(color: Colors.white),
            ),
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
                  'No orders found!',
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
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
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () => _payWithStripe(context), // Navigate to PaymentScreen
                      child: Text('Pay with Stripe'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _payWithStripe(BuildContext context) async {
    // Calculate total amount from orders
    int totalAmount = 0;
    for (var order in orders) {
      totalAmount += (order['quantity'] as int) * 1000; // Converting to cents
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Creating payment intent...'),
          duration: Duration(seconds: 1),
        ),
      );

      final response = await http.post(
        Uri.parse('http://localhost:3100/api/v1/stripe/payment-intent'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'amount': totalAmount,
          'email': userEmail,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final clientSecret = responseData['client_secret'];

        if (clientSecret == null) {
          throw Exception('Client secret not found in response');
        }

        // Navigate to PaymentScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              clientSecret: clientSecret,
              userEmail: userEmail,
            ),
          )).then((value) {
            // After returning from PaymentScreen, navigate to PurchasesPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PurchasesPage(
                  orders: orders.take(10).toList(), // Pass the last 10 orders
                  userEmail: userEmail,
                ),
              ),
            );
          });
      } else {
        throw Exception('Failed to create payment intent: ${response.statusCode}');
      }
    } catch (error) {
      print('Payment error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${error.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
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
                final response = await http.put(
                  Uri.parse('http://localhost:3100/api/v1/users/logout'),
                  headers: {'Content-Type': 'application/json'},
                );

                if (response.statusCode == 200) {
                  final responseData = json.decode(response.body);
                  if (responseData['success']) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Logout successfully"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Logout failed: ${responseData['message']}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Logout failed: Server error"),
                      backgroundColor: Colors.red,
                    ),
                  );
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
}