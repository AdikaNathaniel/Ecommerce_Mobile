import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategoryProducts();
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

          setState(() {
            _categoryProducts[category] = productsData.map((json) => Product.fromJson(json)).toList();
          });
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
                return ExpansionTile(
                  title: Text(category, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  children: _categoryProducts[category]?.map((product) {
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: ListTile(
                            leading: product.image.isNotEmpty
                                ? Image.network(
                                    product.image,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.image_not_supported, size: 50),
                                  )
                                : Icon(Icons.image, size: 50),
                            title: Text(product.productName, style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("\$${product.price}", style: TextStyle(color: Colors.green, fontSize: 16)),
                                Text(product.status, style: TextStyle(color: Colors.grey, fontSize: 14)),
                              ],
                            ),
                          ),
                        );
                      }).toList() ??
                      [],
                );
              },
            ),
    );
  }
}
