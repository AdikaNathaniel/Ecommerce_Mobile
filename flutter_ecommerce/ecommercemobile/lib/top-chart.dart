import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'products.dart';

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
      ),
      body: _isLoading
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
    );
  }
}