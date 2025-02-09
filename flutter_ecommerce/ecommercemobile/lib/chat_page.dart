import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';

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
  List<dynamic> _users = [];
  List<dynamic> _admins = [];
  List<dynamic> _sellers = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final customerResponse = await http.get(Uri.parse('http://localhost:3100/api/v1/users?type=customer'));
      final sellerResponse = await http.get(Uri.parse('http://localhost:3100/api/v1/users?type=seller'));
      final adminResponse = await http.get(Uri.parse('http://localhost:3100/api/v1/users?type=admin'));

      if (customerResponse.statusCode == 200) {
        final data = json.decode(customerResponse.body);
        setState(() {
          _users = data['result'].take(2).toList();
        });
      }
      if (sellerResponse.statusCode == 200) {
        final data = json.decode(sellerResponse.body);
        setState(() {
          _sellers = data['result'].take(2).toList();
        });
      }
      if (adminResponse.statusCode == 200) {
        final data = json.decode(adminResponse.body);
        setState(() {
          _admins = data['result'].take(2).toList();
        });
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

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
        title: Text(
          'Chat Page',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: CircleAvatar(
              child: Text(
                widget.userEmail.isNotEmpty ? widget.userEmail[0].toUpperCase() : 'U',
                style: TextStyle(color: Colors.blue),
              ),
              backgroundColor: Colors.white,
            ),
            onPressed: _showUserInfoDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _sendMessage,
                      icon: Icon(Icons.send),
                      label: Text('Send Message'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    ),
              SizedBox(height: 16),
              Text(
                'Send a message to one of the following emails:',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              _buildUserList('Customers', _users),
              _buildUserList('Sellers', _sellers),
              _buildUserList('Admins', _admins),
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

  Widget _buildUserList(String title, List<dynamic> userList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...userList.map((user) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user['name'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.group, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              user['type'].toString().toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              subtitle: Row(
                children: [
                  Icon(Icons.email, color: Colors.grey, size: 16),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      user['email'],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        SizedBox(height: 16),
      ],
    );
  }

  void _showUserInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Account Details', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.userEmail,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}