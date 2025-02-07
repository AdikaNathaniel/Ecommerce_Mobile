import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddProductPage extends StatefulWidget {
  final String userEmail;
  final String userPassword;

  AddProductPage({required this.userEmail, required this.userPassword});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();
  final _baseTypeController = TextEditingController();
  final _productUrlController = TextEditingController();
  final _downloadUrlController = TextEditingController();
  final _avgRatingController = TextEditingController();
  final _priceController = TextEditingController();
  final _highlightsController = TextEditingController();

  bool _isLoading = false;
  String? _selectedCategory;
  String? _selectedPlatformType;

  void _addProduct() async {
    final productName = _productNameController.text;
    final description = _descriptionController.text;
    final image = _imageController.text;
    final category = _selectedCategory;
    final platformType = _selectedPlatformType;
    final baseType = _baseTypeController.text;
    final productUrl = _productUrlController.text;
    final downloadUrl = _downloadUrlController.text;
    final avgRating = double.tryParse(_avgRatingController.text) ?? 0.0;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final highlights = _highlightsController.text.split(',').map((e) => e.trim()).toList();

    // Validate input fields
    if (productName.isEmpty ||
        description.isEmpty ||
        image.isEmpty ||
        category == null ||
        platformType == null ||
        baseType.isEmpty ||
        price.isNaN) {
      _showSnackbar("All fields are required!", Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://localhost:3100/api/v1/products');

    // Logging for debugging
    print('Email: ${widget.userEmail}');
    print('Password: ${widget.userPassword}');

    final headers = {
      'Content-Type': 'application/json',
      'Role': 'Seller', // Adding the custom role header
    };

    final body = json.encode({
      'productName': productName,
      'description': description,
      'image': image,
      'category': category,
      'platformType': platformType,
      'baseType': baseType,
      'productUrl': productUrl,
      'downloadUrl': downloadUrl,
      'avgRating': avgRating,
      'price': price,
      'highlights': highlights,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      '__v': 0,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        if (response.statusCode == 401) {
          _showSnackbar("Unauthorized: Please check your credentials.", Colors.red);
        } else {
          _showSnackbar("Failed to add product: ${response.body}", Colors.red);
        }
      }
    } catch (e) {
      _showSnackbar("Error: $e", Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 80, color: Colors.green), // Green tick
              SizedBox(height: 10),
              Text(
                "Product Successfully Added!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to previous screen
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green), // Green button
                child: Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

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
        backgroundColor: Colors.blue,
        title: Center(
          child: Text(
            'Add New Product',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Icon(
                Icons.add_box,
                size: 80,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _productNameController,
                decoration: _buildInputDecoration('Product Name', Icons.shopping_bag),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _descriptionController,
                decoration: _buildInputDecoration('Description', Icons.description),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _imageController,
                decoration: _buildInputDecoration('Image URL (Base64)', Icons.image),
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _buildInputDecoration('Category', Icons.category),
                items: ['Operating System', 'Application Software']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedPlatformType,
                decoration: _buildInputDecoration('Platform Type', Icons.devices),
                items: ['Linux', 'Windows', 'MacOS', 'Android', 'iOS']
                    .map((platform) => DropdownMenuItem(
                          value: platform,
                          child: Text(platform),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPlatformType = value;
                  });
                },
              ),
              SizedBox(height: 15),
              TextField(
                controller: _baseTypeController,
                decoration: _buildInputDecoration('Base Type', Icons.layers),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _productUrlController,
                decoration: _buildInputDecoration('Product URL', Icons.link),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _downloadUrlController,
                decoration: _buildInputDecoration('Download URL', Icons.download),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _avgRatingController,
                decoration: _buildInputDecoration('Average Rating', Icons.star_half),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 15),
              TextField(
                controller: _priceController,
                decoration: _buildInputDecoration('Price', Icons.attach_money),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _addProduct,
                      icon: Icon(Icons.add),
                      label: Text('Add Product'),
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
}
