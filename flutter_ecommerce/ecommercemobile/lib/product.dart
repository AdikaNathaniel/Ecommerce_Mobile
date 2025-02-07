class Product {
  final String productName;
  final String description;
  final String category;
  final String platformType;
  final String baseType;
  final String productUrl;
  final String downloadUrl;
  final List<Requirement> requirementSpecification;
  final List<String> highlights;
  final String stripeProductId;
  final String image;
  final List<SkuDetail> skuDetails;

  Product({
    required this.productName,
    required this.description,
    required this.category,
    required this.platformType,
    required this.baseType,
    required this.productUrl,
    required this.downloadUrl,
    required this.requirementSpecification,
    required this.highlights,
    required this.stripeProductId,
    required this.image,
    required this.skuDetails,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productName: json['productName'] ?? 'Unknown Product',
      description: json['description'] ?? 'No description available',
      category: json['category'] ?? 'Unknown',
      platformType: json['platformType'] ?? 'Unknown',
      baseType: json['baseType'] ?? 'Unknown',
      productUrl: json['productUrl'] ?? '',
      downloadUrl: json['downloadUrl'] ?? '',
      requirementSpecification: (json['requirementSpecification'] as List?)
              ?.map((i) => Requirement.fromJson(i))
              .toList() ??
          [],
      highlights: (json['highlights'] as List?)?.cast<String>() ?? [],
      stripeProductId: json['stripeProductId'] ?? '',
      image: json['image'] ??
          'https://us.123rf.com/450wm/pavelstasevich/pavelstasevich1811/pavelstasevich181101027/112815900-no-image-available-icon-flat-vector.jpg?ver=6',
      skuDetails: (json['skuDetails'] as List?)
              ?.map((i) => SkuDetail.fromJson(i))
              .toList() ??
          [],
    );
  }
}

class Requirement {
  final String requirementId;
  final String description;
  final String priority;

  Requirement({
    required this.requirementId,
    required this.description,
    required this.priority,
  });

  factory Requirement.fromJson(Map<String, dynamic> json) {
    return Requirement(
      requirementId: json['requirementId'] ?? '',
      description: json['description'] ?? 'No description provided',
      priority: json['priority'] ?? 'Medium',
    );
  }
}

class SkuDetail {
  final String skuName;
  final double price;
  final int validity;
  final bool lifetime;
  final String stripePriceId;
  final String skuCode;

  SkuDetail({
    required this.skuName,
    required this.price,
    required this.validity,
    required this.lifetime,
    required this.stripePriceId,
    required this.skuCode,
  });

  factory SkuDetail.fromJson(Map<String, dynamic> json) {
    return SkuDetail(
      skuName: json['skuName'] ?? 'Unknown SKU',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      validity: json['validity'] ?? 0,
      lifetime: json['lifetime'] ?? false,
      stripePriceId: json['stripePriceId'] ?? '',
      skuCode: json['skuCode'] ?? '',
    );
  }
}
