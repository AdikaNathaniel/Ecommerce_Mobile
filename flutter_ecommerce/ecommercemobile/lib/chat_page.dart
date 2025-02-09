import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPage extends StatefulWidget {
  final String userEmail;

  ChatPage({required this.userEmail});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _messageController = TextEditingController();
  TextEditingController _receiverEmailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3100/api/v1/chat'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'message': _messageController.text,
          'receiverEmail': _receiverEmailController.text,
        }),
      );

      if (response.statusCode == 201) {
        _showSnackbar("Message sent successfully!", Colors.green);
        _messageController.clear();
        _receiverEmailController.clear();
      } else {
        _showSnackbar("Failed to send message.", Colors.red);
      }
    } catch (e) {
      _showSnackbar("Error connecting to server.", Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackbar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Container(
          width: double.infinity,
          child: Center(
            child: Text(
              'Chat Page',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              child: Text(
                widget.userEmail.isNotEmpty ? widget.userEmail[0].toUpperCase() : 'U',
                style: TextStyle(color: Colors.blue),
              ),
              backgroundColor: Colors.white,
            ),
            onPressed: _showUserInfoDialog, // Show user info dialog
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _receiverEmailController,
                decoration: _buildInputDecoration('Receiver Email', Icons.email),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _messageController,
                decoration: _buildInputDecoration('Message', Icons.message),
                maxLines: 5,
              ),
              SizedBox(height: 16),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _sendMessage,
                      icon: Icon(Icons.send),
                      label: Text('Send Message'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue),
      border: OutlineInputBorder(),
    );
  }

  void _showUserInfoDialog() {
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
                Text(widget.userEmail),
              ],
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}