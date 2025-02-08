class Product {
  final String id;
  final String productName;
  final double price; // Ensure this is a double
  final String status;
  final String image;
  final String category;

  Product({
    required this.id,
    required this.productName,
    required this.price,
    required this.status,
    required this.image,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      productName: json['productName'],
      price: json['price'].toDouble(), // Convert price to double if necessary
      status: json['status'],
      image: json['image'],
      category: json['category'],
    );
  }
}


//This is for the top chart