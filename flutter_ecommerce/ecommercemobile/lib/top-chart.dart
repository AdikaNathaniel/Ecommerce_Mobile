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
    // Clean up scroll controllers and timers
    _scrollControllers.values.forEach((controller) => controller.dispose());
    _scrollTimers.values.forEach((timer) => timer?.cancel());
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
          
          // Double the products list to create a seamless infinite scroll effect
          List<Product> products = productsData.map((json) => Product.fromJson(json)).toList();
          products = [...products, ...products];

          setState(() {
            _categoryProducts[category] = products;
          });

          // Start auto-scrolling for this category
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

      // Reset to beginning when reaching end
      if (newOffset >= controller.position.maxScrollExtent) {
        newOffset = 0;
      }

      controller.jumpTo(newOffset);
    });
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 120,
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                product.image,
                height: 80,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.image_not_supported, size: 80),
              ),
            ),
            SizedBox(height: 4),
            Flexible(
              child: Text(
                product.productName,
                style: TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              "\$${product.price.toString()}",
              style: TextStyle(color: Colors.green),
            ),
            Text(
              product.status,
              style: TextStyle(color: Colors.grey, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Top Charts")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                String category = _categories[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        category,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    SizedBox(
                      height: 170,
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
                );
              },
            ),
    );
  }
}