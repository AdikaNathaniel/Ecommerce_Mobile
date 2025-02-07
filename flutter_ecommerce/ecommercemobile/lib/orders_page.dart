import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrdersPage extends StatelessWidget {
  final List<dynamic> orders;
  final String userEmail;

  OrdersPage({required this.orders, required this.userEmail});

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
    // Calculate total amount from orders
    int totalAmount = 0;
    for (var order in orders) {
      totalAmount += (order['quantity'] as int) * 1000; // Converting to cents
    }

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Creating payment intent...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Call your backend to create a payment intent
      final response = await http.post(
        Uri.parse('http://localhost:3100/api/v1/stripe/payment-intent'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'amount': totalAmount,
          'email': userEmail,
        }),
      );

      // Check for successful payment intent creation (201 status)
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment intent created successfully! (Status: 201)'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        final responseData = json.decode(response.body);
        final clientSecret = responseData['client_secret'];

        if (clientSecret == null) {
          throw Exception('Client secret not found in response');
        }

        // Confirm the payment with Stripe
        await stripe.Stripe.instance.confirmPayment(
          paymentIntentClientSecret: clientSecret,
          data: stripe.PaymentMethodParams.card(
            paymentMethodData: stripe.PaymentMethodData(
              billingDetails: stripe.BillingDetails(
                email: userEmail,
              ),
            ),
          ),
        );

        // Show final success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment processed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        throw Exception('Failed to create payment intent: ${response.statusCode}');
      }
    } catch (error) {
      print('Payment error: $error'); // For debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${error.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }
}