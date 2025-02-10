import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'main.dart';

class OTPVerificationPage extends StatefulWidget {
  final String email;

  const OTPVerificationPage({Key? key, required this.email}) : super(key: key);

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  String otp = "";
  bool _isLoading = false;

  Future<void> verifyOTP() async {
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://localhost:3100/api/v1/users/verify-email/$otp/${widget.email}');
    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['message'] == "Email verified successfully. You can log in now.") {
        showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Verification failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

 void showSuccessDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Icon(Icons.check_circle, color: Colors.blue, size: 50),
        content: Text("Email verified successfully. You can log in now."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog first
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button
        backgroundColor: Colors.blue,
        title: Container(
          width: double.infinity, // Take full width
          child: Center(
            child: Text(
              'Verify Your Email',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.blue[50],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter the 6-digit OTP sent to ${widget.email}", textAlign: TextAlign.center),
            SizedBox(height: 20),
            OtpTextField(
              numberOfFields: 6,
              borderColor: Colors.blue,
              showFieldAsBox: true,
              onSubmit: (code) {
                otp = code;
              },
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: verifyOTP,
                    child: Text("Verify"),
                  ),
          ],
        ),
      ),
    );
  }
}
