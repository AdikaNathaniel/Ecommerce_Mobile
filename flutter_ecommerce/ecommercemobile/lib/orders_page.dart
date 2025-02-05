import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  final List<dynamic> orders; // List of orders passed from MyCartPage

  OrdersPage({required this.orders});

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
        color: Colors.blue[50], // Light blue background
        child: orders.isEmpty
            ? Center(
                child: Text(
                  'No orders found!',
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
              )
            : ListView.builder(
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
                          '${index + 1}', // Order number
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
    );
  }
}