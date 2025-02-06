import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

class PaymentScreen extends StatefulWidget {
  final String clientSecret;
  final String userEmail;

  PaymentScreen({required this.clientSecret, required this.userEmail});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Container(
          width: double.infinity,
          child: Center(
            child: Text(
              'Payment',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.blue[50],
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Email: ${widget.userEmail}'),
                    SizedBox(height: 20),
                    Container(
                      height: 200,
                      child: stripe.CardField(
                        onCardChanged: (details) {
                          // Optional: handle card changes
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handlePayment,
              child: Text(
                'Complete Payment',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePayment() async {
    try {
      // For web, we need to explicitly create payment method params
      final params = stripe.PaymentMethodParams.card(
        paymentMethodData: stripe.PaymentMethodData(
          billingDetails: stripe.BillingDetails(
            email: widget.userEmail,
          ),
        ),
      );

      // Confirm the payment with required parameters
      final paymentIntent = await stripe.Stripe.instance.confirmPayment(
        paymentIntentClientSecret: widget.clientSecret,
        data: params, // This is required for web
      );

      if (paymentIntent.status == stripe.PaymentIntentsStatus.Succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment successful!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('Payment error: $e'); // Add this for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}