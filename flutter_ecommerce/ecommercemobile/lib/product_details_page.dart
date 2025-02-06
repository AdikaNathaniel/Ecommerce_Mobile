import 'package:flutter/material.dart';
import 'product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_details.dart'; // Import the CartDetailsPage

class ProductDetailsPage extends StatelessWidget {
  final Product product;
  final String userEmail; // Add userEmail parameter
  bool isInCart = false; // Track if the product is in the cart

  ProductDetailsPage({required this.product, required this.userEmail}); // Update constructor

  // Function to add product to cart
  Future<void> _addToCart(BuildContext context) async {
    final quantity = await _showQuantityDialog(context);
    if (quantity == null) return; // User canceled the dialog

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3100/api/v1/cart'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'productName': product.productName,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 201) {
        isInCart = true; // Mark product as added to cart
        _showSnackbar(context, "Product added to cart!", Colors.green);
      } else {
        if (response.statusCode == 400) {
          _showSnackbar(context, "Product is already in the cart.", Colors.orange);
        } else {
          _showSnackbar(context, "Failed to add to cart.", Colors.red);
        }
      }
    } catch (error) {
      _showSnackbar(context, "Error connecting to server.", Colors.red);
    }
  }

  // Function to remove product from cart
  Future<void> _removeFromCart(BuildContext context) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3100/api/v1/cart?productName=${product.productName}'),
      );

      if (response.statusCode == 200) {
        isInCart = false; // Mark product as removed from cart
        _showSnackbar(context, "Product removed from cart!", Colors.green);
      } else {
        if (response.statusCode == 400) {
          _showSnackbar(context, "Product not found in cart.", Colors.orange);
        } else {
          _showSnackbar(context, "Failed to remove from cart.", Colors.red);
        }
      }
    } catch (error) {
      _showSnackbar(context, "Error connecting to server.", Colors.red);
    }
  }

  // Function to edit cart details
  Future<void> _editCartItem(BuildContext context) async {
    if (!isInCart) {
      _showSnackbar(context, "Product not added to cart yet.", Colors.red);
      return;
    }

    final quantity = await _showQuantityDialog(context);
    if (quantity == null) return; // User canceled the dialog

    try {
      final response = await http.put(
        Uri.parse('http://localhost:3100/api/v1/cart'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'productName': product.productName,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200) {
        _showSnackbar(context, "Cart item updated!", Colors.green);
      } else {
        _showSnackbar(context, "Failed to update cart item.", Colors.red);
      }
    } catch (error) {
      _showSnackbar(context, "Error connecting to server.", Colors.red);
    }
  }

  // Show quantity input dialog
  Future<int?> _showQuantityDialog(BuildContext context) {
    final TextEditingController _quantityController = TextEditingController();

    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Quantity'),
          content: TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Quantity'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final quantity = int.tryParse(_quantityController.text);
                Navigator.of(context).pop(quantity);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show snackbar messages at the top
  void _showSnackbar(BuildContext context, String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    // Show snackbar at the top
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
              'Product Details',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.blue[50], // Set the background color
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                product.image,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    'https://us.123rf.com/450wm/pavelstasevich/pavelstasevich1811/pavelstasevich181101027/112815900-no-image-available-icon-flat-vector.jpg?ver=6',
                    fit: BoxFit.cover,
                  );
                },
              ),
              SizedBox(height: 16),
              Text('Description: ${product.description}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Category: ${product.category}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Platform: ${product.platformType}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Base Type: ${product.baseType}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Product URL: ${product.productUrl}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Download URL: ${product.downloadUrl}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              Text('Highlights:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ...product.highlights.map((highlight) => Text('- $highlight')).toList(),
              SizedBox(height: 16),
              Text('Requirements:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ...product.requirementSpecification.map((req) => Text('- ${req.description} (${req.priority})')).toList(),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Align buttons horizontally
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _addToCart(context),
                      child: Text('Add to Cart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10), // Spacing between buttons
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _removeFromCart(context),
                      child: Text('Remove from Cart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10), // Spacing between buttons
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _editCartItem(context),
                      child: Text('Edit Cart Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10), // Spacing between buttons
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyCartPage(userEmail: userEmail), // Pass userEmail
                          ),
                        );
                      },
                      child: Text('View My Cart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 15),
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
}