import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'user_screen.dart';

class SummaryPage extends StatelessWidget {
  final int totalProducts;
  final int totalItemsInCart;
  final int totalOrders;
  final int totalUsers;

  const SummaryPage({
    required this.totalProducts,
    required this.totalItemsInCart,
    required this.totalOrders,
    required this.totalUsers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Center(
          child: Text(
            'Digizone Business Insights',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildSummaryCard(
                    context,
                    title: 'Total Products',
                    value: totalProducts,
                    icon: Icons.production_quantity_limits, // Replaced icon
                    color: Colors.orangeAccent,
                  ),
                  _buildSummaryCard(
                    context,
                    title: 'Items in Cart',
                    value: totalItemsInCart,
                    icon: Icons.shopping_cart, // Replaced icon
                    color: Colors.redAccent,
                  ),
                  _buildSummaryCard(
                    context,
                    title: 'Total Orders',
                    value: totalOrders,
                    icon: Icons.receipt_long, // Replaced icon
                    color: Colors.greenAccent,
                  ),
                  _buildSummaryCard(
                    context,
                    title: 'Total Users',
                    value: totalUsers,
                    icon: Icons.people, // Replaced icon
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserListScreen()),
    );
  },
  child: Text('View Users On Digizone', style: TextStyle(fontSize: 18)),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blueAccent,
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

  Widget _buildSummaryCard(BuildContext context,
      {required String title, required int value, required IconData icon, required Color color}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: title,
            child: Icon(icon, size: 50, color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            value.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}