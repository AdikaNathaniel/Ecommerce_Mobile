import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  String selectedType = 'customer'; // Default user type
  List<dynamic> users = [];
  int customers = 0, sellers = 0, admins = 0;

  @override
  void initState() {
    super.initState();
    fetchUsers('customer');
    fetchCounts();
  }

  Future<void> fetchUsers(String type) async {
    final url = Uri.parse('http://localhost:3100/api/v1/users?type=$type');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        users = data['result'];
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> fetchCounts() async {
    List<String> types = ['customer', 'seller', 'admin'];
    Map<String, int> counts = {};

    for (String type in types) {
      final url = Uri.parse('http://localhost:3100/api/v1/users?type=$type');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        counts[type] = data['result'].length;
      }
    }

    setState(() {
      customers = counts['customer'] ?? 0;
      sellers = counts['seller'] ?? 0;
      admins = counts['admin'] ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Center(
          child: Text(
            'Users Registered On Digizone',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Column(
        children: [
          // Dropdown for filtering users
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedType,
              items: ['customer', 'seller', 'admin'].map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type.toUpperCase()),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedType = newValue;
                    fetchUsers(newValue);
                  });
                }
              },
            ),
          ),

          // Expanded ListView for user list
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  elevation: 5,
                  child: ListTile(
                    leading: Icon(Icons.person, color: Colors.blue),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(user['name']),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.group, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                user['type'].toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Icon(Icons.email, color: Colors.grey),
                        SizedBox(width: 5),
                        Expanded(child: Text(user['email'])),
                      ],
                    ),
                    trailing: user['isVerified']
                        ? Icon(Icons.verified, color: Colors.green)
                        : Icon(Icons.cancel, color: Colors.red),
                  ),
                );
              },
            ),
          ),

          // User Type Counts Section
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    'User Counts',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: _buildCountCard('Customers', customers)),
                      Expanded(child: _buildCountCard('Sellers', sellers)),
                      Expanded(child: _buildCountCard('Admins', admins)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountCard(String title, int count) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5), // Adds spacing between the cards
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 2, blurRadius: 5),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ensures it doesn't take excess space
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(count.toString(), style: TextStyle(fontSize: 24, color: Colors.blue)),
        ],
      ),
    );
  }
}
