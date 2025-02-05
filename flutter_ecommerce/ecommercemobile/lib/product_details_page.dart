import 'package:flutter/material.dart';
import 'product.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;

  ProductDetailsPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.productName),
      ),
      body: SingleChildScrollView( // Make the body scrollable
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
          ],
        ),
      ),
    );
  }
}