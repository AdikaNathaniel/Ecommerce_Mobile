import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart'; // Import your LoginPage
import 'product_page.dart'; // Import ProductsPage
import 'top-chart.dart'; // Import TopChartsPage
import 'purchases.dart'; // Import PurchasesPage
import 'product.dart'; // Your Product model

class FavoritesPage extends StatefulWidget {
  final String userEmail;

  const FavoritesPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Product> _favorites = [];
  bool _isLoading = true;

  int _selectedIndex = 2; // Set to 2 for Favorites
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3100/api/v1/favorite'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> favoritesData = data['result'];

        setState(() {
          _favorites = favoritesData.map((json) => Product.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load favorites');
      }
    } catch (e) {
      print('Error fetching favorites: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addFavorite() async {
    final productName = _productNameController.text;
    final category = _categoryController.text;
    final image = _imageController.text;

    if (productName.isEmpty || image.isEmpty) {
      _showSnackbar("Product Name and Image are required!", Colors.red);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3100/api/v1/favorite'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'productName': productName,
        //   'status': status,
          'image': image,
          'category': category, 
        }),
      );

      if (response.statusCode == 201) {
        _showSnackbar("Favorite added!", Colors.green);
        _fetchFavorites(); // Refresh favorites
      } else {
        _showSnackbar("Failed to add favorite.", Colors.red);
      }
    } catch (error) {
      _showSnackbar("Error connecting to server.", Colors.red);
    }
  }

  Future<void> _removeFavorite(String productName) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3100/api/v1/favorite/$productName'),
      );

      if (response.statusCode == 200) {
        _showSnackbar("Favorite removed!", Colors.green);
        _fetchFavorites(); // Refresh favorites
      } else {
        _showSnackbar("Failed to remove favorite.", Colors.red);
      }
    } catch (error) {
      _showSnackbar("Error connecting to server.", Colors.red);
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
              'Favorites',
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
            onPressed: _showUserInfoDialog,
          ),
        ],
      ),
      body: Container(
        color: Colors.blue[50],
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _productNameController,
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: 'Category(Action, Adventure,Board,Eductational or Sports)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _imageController,
                      decoration: InputDecoration(
                        labelText: 'Image URL',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _addFavorite,
                        child: Text('Add Favorite'),
                      ),
                    //   ElevatedButton(
                    //     onPressed: () => _removeFavorite(_productNameController.text),
                    //     child: Text('Remove Favorite'),
                    //   ),
                    //   ElevatedButton(
                    //     onPressed: _fetchFavorites,
                    //     child: Text('View Favorites'),
                    //   ),
                    ],
                  ),
                  Expanded(
                    child: _favorites.isEmpty
                        ? Center(child: Text('No favorites found.'))
                        : ListView.builder(
                            itemCount: _favorites.length,
                            itemBuilder: (context, index) {
                              final product = _favorites[index];
                              return Card(
                                elevation: 4,
                                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                child: ListTile(
                                  leading: Image.network(
                                    product.image,
                                    width: 50,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.network(
                                        'https://us.123rf.com/450wm/pavelstasevich/pavelstasevich1811/pavelstasevich181101027/112815900-no-image-available-icon-flat-vector.jpg?ver=6',
                                      );
                                    },
                                  ),
                                  title: Text(product.productName),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeFavorite(product.productName),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
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
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Handle navigation
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProductsPage(userEmail: widget.userEmail)),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TopChartsPage(userEmail: widget.userEmail)),
              );
              break;
            case 2:
              // Already on FavoritesPage
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PurchasesPage(userEmail: widget.userEmail)),
              );
              break;
          }
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        showSelectedLabels: true,
      ),
    );
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
}