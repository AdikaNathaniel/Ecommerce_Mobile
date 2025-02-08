import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'orders_page.dart'; // Import the OrdersPage here
import 'main.dart'; // Import your LoginPage

class MyCartPage extends StatefulWidget {
  final String userEmail; // Add userEmail parameter

  MyCartPage({required this.userEmail}); // Update constructor to accept userEmail

  @override
  _MyCartPageState createState() => _MyCartPageState();
}

class _MyCartPageState extends State<MyCartPage> {
  List<dynamic> cartItems = [];

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  // Fetch cart items from the server
  Future<void> _fetchCartItems() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3100/api/v1/cart'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          cartItems = data['result']; // Adjust the key based on your API response
        });
      } else {
        _showSnackbar("Failed to load cart items.", Colors.red);
      }
    } catch (error) {
      _showSnackbar("Error connecting to server.", Colors.red);
    }
  }

  // Function to place an order
  Future<void> _placeOrder(String productName, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3100/api/v1/orders'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'productName': productName,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 201) {
        _showSnackbar("Order placed successfully!", Colors.green);
      } else {
        _showSnackbar("Failed to place order.", Colors.red);
      }
    } catch (error) {
      _showSnackbar("Error connecting to server.", Colors.red);
    }
  }

  // Function to cancel all orders based on cart items
  Future<void> _cancelAllOrders() async {
    if (cartItems.isEmpty) {
      _showSnackbar("No items to cancel.", Colors.red);
      return;
    }

    for (var item in cartItems) {
      await _cancelOrder(item['productName']);
    }
  }

  // Function to cancel an individual order
  Future<void> _cancelOrder(String productName) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3100/api/v1/orders/cancel'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'productName': productName}),
      );

      if (response.statusCode == 200) {
        _showSnackbar("Order for $productName cancelled successfully!", Colors.green);
      } else {
        _showSnackbar("Failed to cancel order for $productName.", Colors.red);
      }
    } catch (error) {
      _showSnackbar("Error connecting to server.", Colors.red);
    }
  }

  // Show snackbar messages
  void _showSnackbar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Function to navigate to orders page
  Future<void> _navigateToOrdersPage() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3100/api/v1/orders?email=${widget.userEmail}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrdersPage(orders: data['result'], userEmail: widget.userEmail), // Pass userEmail to OrdersPage
          ),
        );
      } else {
        _showSnackbar("Failed to load orders.", Colors.red);
      }
    } catch (error) {
      _showSnackbar("Error connecting to server.", Colors.red);
    }
  }

  // Show user info dialog
  void _showUserInfoDialog() {
    String email = widget.userEmail; 
    String role = 'Customer'; // Hardcoded role

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
                Text(email),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person),
                SizedBox(width: 10),
                Text(role),
              ],
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                // Call logout API
                final response = await http.put(
                  Uri.parse('http://localhost:3100/api/v1/users/logout'),
                  headers: {'Content-Type': 'application/json'},
                );

                if (response.statusCode == 200) {
                  final responseData = json.decode(response.body);
                  if (responseData['success']) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Logout successfully"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Logout failed: ${responseData['message']}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Logout failed: Server error"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
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
              'My Cart',
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
      body: Container(
        color: Colors.blue[50], // Light blue background
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20), // Space between title and list
              cartItems.isEmpty
                  ? Text(
                      'Your cart is empty!',
                      style: TextStyle(fontSize: 18, color: Colors.blue),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            elevation: 4,
                            child: ListTile(
                              leading: Icon(Icons.shopping_cart, size: 40, color: Colors.blue),
                              title: Text(item['productName'], style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Quantity: ${item['quantity']}'),
                              trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                              onTap: () {
                                // You can add functionality to view more details about the product
                              },
                            ),
                          );
                        },
                      ),
                    ),
              SizedBox(height: 20), // Space before the button row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space buttons evenly
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Loop through cart items and place orders
                      for (var item in cartItems) {
                        _placeOrder(item['productName'], item['quantity']);
                      }
                    },
                    child: Text('Place Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Button color
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _navigateToOrdersPage, // Navigate to OrdersPage
                    child: Text('View My Orders'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Button color
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _cancelAllOrders, // Cancel all orders
                    child: Text('Cancel All Orders'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Button color
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
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
}