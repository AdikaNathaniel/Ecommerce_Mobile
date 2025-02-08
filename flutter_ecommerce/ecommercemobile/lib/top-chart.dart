import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'products.dart';
import 'main.dart'; // Import your LoginPage
import 'favorite.dart';
import 'purchases.dart';
import 'orders_page.dart'; // Import your OrdersPage
import 'product_page.dart'; // Import your ProductsPage

class TopChartsPage extends StatefulWidget {
  final String userEmail;

  const TopChartsPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  _TopChartsPageState createState() => _TopChartsPageState();
}

class _TopChartsPageState extends State<TopChartsPage> {
  final List<String> _categories = ["Action", "Adventure", "Board", "Educational", "Sports"];
  Map<String, List<Product>> _categoryProducts = {};
  Map<String, ScrollController> _scrollControllers = {};
  Map<String, Timer?> _scrollTimers = {};
  bool _isLoading = true;

  int _selectedIndex = 1; // Set to 1 for Top Charts

  @override
  void initState() {
    super.initState();
    _initializeScrollControllers();
    _fetchCategoryProducts();
  }

  void _initializeScrollControllers() {
    for (String category in _categories) {
      _scrollControllers[category] = ScrollController();
    }
  }

  @override
  void dispose() {
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    for (var timer in _scrollTimers.values) {
      timer?.cancel();
    }
    super.dispose();
  }

  Future<void> _fetchCategoryProducts() async {
    try {
      for (String category in _categories) {
        final response = await http.get(
          Uri.parse('http://localhost:3100/api/v1/top-charts/filter/category?category=$category'),
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> data = json.decode(response.body);
          List<dynamic> productsData = data['result'];

          List<Product> products = productsData.map((json) => Product.fromJson(json)).toList();
          products = [...products, ...products];

          setState(() {
            _categoryProducts[category] = products;
          });

          _startAutoScroll(category);
        } else {
          throw Exception('Failed to load products for $category');
        }
      }
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startAutoScroll(String category) {
    const duration = Duration(milliseconds: 50);
    const scrollStep = 1.0;

    _scrollTimers[category]?.cancel();
    _scrollTimers[category] = Timer.periodic(duration, (timer) {
      if (!_scrollControllers[category]!.hasClients) return;

      final ScrollController controller = _scrollControllers[category]!;
      double newOffset = controller.offset + scrollStep;

      if (newOffset >= controller.position.maxScrollExtent) {
        newOffset = 0;
      }

      controller.jumpTo(newOffset);
    });
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 4,
      child: Container(
        width: 250,
        height: 250, // Increased height for better layout
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                product.image,
                height: 120, // Increased image height for better visibility
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.network(
                  'https://us.123rf.com/450wm/pavelstasevich/pavelstasevich1811/pavelstasevich181101027/112815900-no-image-available-icon-flat-vector.jpg?ver=6',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              product.productName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16),
                SizedBox(width: 4),
                Text("\$${product.price.toString()}", style: TextStyle(color: Colors.green)),
              ],
            ),
            Row(
              children: [
                Icon(Icons.check_circle, size: 16),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    product.status,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
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
          width: double.infinity,
          child: Center(
            child: Text(
              'Top Charts',
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
            onPressed: () {
              // Show user info dialog (similar to ProductsPage)
              _showUserInfoDialog();
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.blue[50], // Set the background color to light blue
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  String category = _categories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              category,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 240, // Increased height for better presentation
                          child: ListView.builder(
                            controller: _scrollControllers[category],
                            scrollDirection: Axis.horizontal,
                            itemCount: _categoryProducts[category]?.length ?? 0,
                            itemBuilder: (context, productIndex) {
                              final product = _categoryProducts[category]![productIndex];
                              return _buildProductCard(product);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Top Charts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Purchases',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue, // Color for the selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
        showUnselectedLabels: true, // Show labels for unselected items
        showSelectedLabels: true, // Show labels for selected item
      ),
    );
  }

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
                    _showSuccessDialog("Logout successfully");
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  } else {
                    _showSnackbar("Logout failed: ${responseData['message']}", Colors.red);
                  }
                } else {
                  _showSnackbar("Logout failed: Server error", Colors.red);
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

  // Function to show success dialog
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

  // Function to show snackbar
  void _showSnackbar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Handle bottom navigation bar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to the corresponding page
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProductsPage(userEmail: widget.userEmail)),
        );
        break;
      case 1:
        // Already on TopChartsPage
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FavoritesPage(userEmail: widget.userEmail)),
        );
        break;
      case 3:
        // You need to provide orders here
        List<dynamic> yourOrdersList = []; // Replace with your actual logic to fetch orders
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PurchasesPage(
              orders: yourOrdersList.take(10).toList(), // Pass the last 10 orders
              userEmail: widget.userEmail,
            ),
          ),
        );
        break;
    }
  }
}