import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_product.dart'; // Import your AddProductPage

class DeliveryManagementPage extends StatefulWidget {
  @override
  _DeliveryManagementPageState createState() => _DeliveryManagementPageState();
}

class _DeliveryManagementPageState extends State<DeliveryManagementPage> {
  final _productNameController = TextEditingController();
  final _trackingIdController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _deliveryStatusController = TextEditingController();
  final _getStatusProductNameController = TextEditingController();

  String _statusMessage = '';
  bool _isLoading = false;

  Future<void> _createDelivery() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3100/api/v1/delivery/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'productName': _productNameController.text,
          'status': _deliveryStatusController.text,
          'trackingId': _trackingIdController.text,
          'deliveryAddress': _deliveryAddressController.text,
        }),
      );

      if (response.statusCode == 201) {
        _showSuccessDialog('Delivery Created Successfully!');
      } else {
        setState(() {
          _statusMessage = 'Failed to Create Delivery!';
        });
      }
    } catch (error) {
      setState(() {
        _statusMessage = 'Error: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateDeliveryStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.put(
        Uri.parse('http://localhost:3100/api/v1/delivery/update/${_productNameController.text}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': _deliveryStatusController.text}),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog('Delivery Status Updated Successfully!');
      } else {
        setState(() {
          _statusMessage = 'Failed to Update Delivery Status!';
        });
      }
    } catch (error) {
      setState(() {
        _statusMessage = 'Error: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getDeliveryStatus() async {
    final productName = _getStatusProductNameController.text;
    if (productName.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter a product name.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3100/api/v1/delivery/status/$productName'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String updatedStatus = _deliveryStatusController.text; 
        _showDeliveryStatusDialog(data['productName'], updatedStatus); 
      } else {
        setState(() {
          _statusMessage = 'Failed to Fetch Delivery Status!';
        });
      }
    } catch (error) {
      setState(() {
        _statusMessage = 'Error: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Icon(Icons.check_circle, color: Colors.green, size: 50),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeliveryStatusDialog(String productName, String status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delivery Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Product Name: $productName'),
            Text('Status: $status'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showProductNameDialog(Function onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Product Name'),
        content: TextField(
          controller: _getStatusProductNameController,
          decoration: InputDecoration(
            labelText: 'Product Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text('Confirm'),
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
              'Delivery Management Store',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: Text(
                  'DIGIZONE - SELLER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.add_box),
              title: Text('Add Product'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProductPage(
                      userEmail: 'user@example.com', // Pass the actual email
                      userPassword: 'password123', // Pass the actual password
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
                labelStyle: TextStyle(color: Colors.blue),
                prefixIcon: Icon(Icons.local_shipping, color: Colors.blue),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _trackingIdController,
              decoration: InputDecoration(
                labelText: 'Tracking ID',
                labelStyle: TextStyle(color: Colors.blue),
                prefixIcon: Icon(Icons.track_changes, color: Colors.blue),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _deliveryAddressController,
              decoration: InputDecoration(
                labelText: 'Delivery Address',
                labelStyle: TextStyle(color: Colors.blue),
                prefixIcon: Icon(Icons.home, color: Colors.blue),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _deliveryStatusController,
              decoration: InputDecoration(
                labelText: 'Delivery Status (Pending, In Transit, Delivered, Cancelled)',
                labelStyle: TextStyle(color: Colors.blue),
                prefixIcon: Icon(Icons.assignment, color: Colors.blue),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _createDelivery,
                        child: Text('Create Delivery'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                ElevatedButton(
                  onPressed: () => _showProductNameDialog(_updateDeliveryStatus),
                  child: Text('Update Status'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showProductNameDialog(_getDeliveryStatus),
                  child: Text('Get Status'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}