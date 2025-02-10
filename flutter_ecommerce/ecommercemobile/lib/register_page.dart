import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart'; // Import for rootBundle
import 'dart:html' as html; // Import for web download
import 'otp_page.dart'; // Import the OTP verification page

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _typeController = TextEditingController(); // New controller for user type
  bool _isLoading = false;

  // Function to handle registration
  Future<void> _register() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final type = _typeController.text; // Get user type from the new field

    // Validate fields
    if (name.isEmpty || email.isEmpty || password.isEmpty || type.isEmpty) {
      _showError("All fields are required!");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3100/api/v1/users'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'type': type, // Include user type in the request
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 && responseData['success']) {
        _showSuccess("Registration successful", email); // Pass email to success dialog
      } else {
        _showError(responseData['message'] ?? "Something went wrong.");
      }
    } catch (error) {
      _showError("Failed to connect to the server.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show error messages in dialog
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Center(child: Text('Error')),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  // Show success messages in dialog and navigate to OTP page
  void _showSuccess(String message, String email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Center(child: Text('You are a registered DigiGamer!')),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OTPVerificationPage(email: email), // Navigate to OTP page
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Function to download the PDF
  Future<void> _downloadPDF() async {
    final ByteData bytes = await rootBundle.load('Gaming_Ecommerce_Terms.pdf');
    final buffer = bytes.buffer.asUint8List();

    // Create a blob and trigger a download
    final blob = html.Blob([buffer], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'Gaming_Ecommerce_Terms.pdf')
      ..click();
    html.Url.revokeObjectUrl(url); // Clean up the URL
  }

  // Show Snackbar for messages
  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
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
              'Register To Digizone',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.account_circle,
              size: 80,
              color: Colors.blue,
            ),
            SizedBox(height: 30),

            // Name input field with icon
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: Colors.blue),
                prefixIcon: Icon(Icons.person, color: Colors.blue), // Name icon
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 15),

            // Email input field with icon
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.blue),
                prefixIcon: Icon(Icons.email, color: Colors.blue), // Email icon
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 15),

            // Password input field with icon
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.blue),
                prefixIcon: Icon(Icons.lock, color: Colors.blue), // Password icon
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              obscureText: true,
            ),
            SizedBox(height: 15),

            // User type input field with icon
            TextField(
              controller: _typeController,
              decoration: InputDecoration(
                labelText: 'User Type',
                labelStyle: TextStyle(color: Colors.blue),
                prefixIcon: Icon(Icons.person_outline, color: Colors.blue), // User type icon
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),

            // Loading indicator or Register button
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: Text('Register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
            SizedBox(height: 20),

            // Create Account link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Go back to the login page
                  },
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Terms of Service and Privacy Policy
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("By clicking Register, you agree to "),
                GestureDetector(
                  onTap: _downloadPDF,
                  child: Text(
                    "our Terms of Service and Privacy Policy",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}