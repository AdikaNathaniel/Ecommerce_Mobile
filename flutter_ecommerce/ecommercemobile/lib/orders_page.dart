import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'payment_screen.dart'; // Import the PaymentScreen

class OrdersPage extends StatelessWidget {
  final List<dynamic> orders;
  final String userEmail;

  OrdersPage({required this.orders, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Center(
          child: Text(
            'My Orders',
            style: TextStyle(color: Colors.white),
          ),
        ),
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
                      onPressed: () => _payWithStripe(context),
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
    int totalAmount = 0;
    for (var order in orders) {
      totalAmount += (order['quantity'] as int) * 1000; // Convert to cents
    }

    try {
      // Call your backend to create a payment intent
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

        // Navigate to PaymentScreen with clientSecret
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(clientSecret: clientSecret, userEmail: userEmail),
          ),
        );
      } else {
        throw Exception('Failed to create payment intent: ${response.statusCode}');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}