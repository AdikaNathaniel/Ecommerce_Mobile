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
  String paymentStatus = 'Pending'; // Initial payment status
  bool isPaymentSuccessful = false; // Flag to control dialog display

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Center(
          child: Text(
            'Payment',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Container(
        color: Colors.blue[50],
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Email:',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                widget.userEmail,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20),
              Text(
                'Card Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Container(
                height: 200,
                child: stripe.CardField(
                  onCardChanged: (details) {
                    // Optional: handle card changes
                  },
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Payment Status: $paymentStatus', // Show current status
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: paymentStatus == 'Pending'
                      ? Colors.orange
                      : Colors.green,
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
      ),
    );
  }

  Future<void> _handlePayment() async {
    try {
      setState(() {
        paymentStatus = 'Pending'; // Set status to pending when starting payment
      });

      // Create payment method params
      final params = stripe.PaymentMethodParams.card(
        paymentMethodData: stripe.PaymentMethodData(
          billingDetails: stripe.BillingDetails(
            email: widget.userEmail,
          ),
        ),
      );

      // Confirm the payment
      final paymentIntent = await stripe.Stripe.instance.confirmPayment(
        paymentIntentClientSecret: widget.clientSecret,
        data: params,
      );

      if (paymentIntent.status == stripe.PaymentIntentsStatus.Succeeded) {
        setState(() {
          paymentStatus = 'Success'; // Update status to success
          isPaymentSuccessful = true; // Trigger success dialog
        });

        // Show success dialog
        _showPaymentSuccessDialog();
      }
    } catch (e) {
      print('Payment error: $e'); // Debugging
      setState(() {
        paymentStatus = 'Failed'; // Update status to failed
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 80,
          ),
          content: Text(
            'Payment Successful!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true); // Close the screen after success
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
