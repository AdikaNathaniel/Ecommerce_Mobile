import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'orders_page.dart'; // Import OrdersPage
import 'delivery_tracker.dart'; // Import DeliveryTracker

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
  bool isProcessingPayment = false; // Flag to manage button state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Center(
          child: Text(
            'Payment Portal',
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
              Center(
                child: Text(
                  'Payment Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Row for Email
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Email:',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 8), // Space between label and email
                  Text(
                    widget.userEmail,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Centered Card Information
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Card Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 200,
                      width: double.infinity, // Ensures it takes the full width
                      child: stripe.CardField(
                        onCardChanged: (details) {
                          // Optional: handle card changes
                        },
                      ),
                    ),
                  ],
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
              // Row for buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isProcessingPayment ? null : _handlePayment, // Disable button if processing
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
                  ),
                  SizedBox(width: 16), // Space between buttons
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _cancelPayment,
                      child: Text(
                        'Cancel Payment',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
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
        isProcessingPayment = true; // Set the processing flag
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
    } finally {
      setState(() {
        isProcessingPayment = false; // Reset the processing flag
      });
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
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => DeliveryTracker(userEmail: widget.userEmail),
                  ),
                ); // Navigate to DeliveryTracker
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _cancelPayment() {
    // Simply pop the current screen to go back to the previous screen (OrdersPage)
    Navigator.of(context).pop();
  }
}