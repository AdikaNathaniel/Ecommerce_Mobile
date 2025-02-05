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
  final String image; // Add this line to include the image property
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
    required this.image, // Include image in constructor
    required this.skuDetails,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var requirementsFromJson = json['requirementSpecification'] as List;
    List<Requirement> requirementsList = requirementsFromJson.map((i) => Requirement.fromJson(i)).toList();

    var highlightsFromJson = json['highlights'] as List;
    List<String> highlightsList = highlightsFromJson.cast<String>();

    var skuDetailsFromJson = json['skuDetails'] as List;
    List<SkuDetail> skuDetailsList = skuDetailsFromJson.map((i) => SkuDetail.fromJson(i)).toList();

    return Product(
      productName: json['productName'],
      description: json['description'],
      category: json['category'],
      platformType: json['platformType'],
      baseType: json['baseType'],
      productUrl: json['productUrl'],
      downloadUrl: json['downloadUrl'],
      requirementSpecification: requirementsList,
      highlights: highlightsList,
      stripeProductId: json['stripeProductId'],
      image: json['image'] ?? 'https://us.123rf.com/450wm/pavelstasevich/pavelstasevich1811/pavelstasevich181101027/112815900-no-image-available-icon-flat-vector.jpg?ver=6', // Default image
      skuDetails: skuDetailsList,
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
      requirementId: json['requirementId'],
      description: json['description'],
      priority: json['priority'],
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
      skuName: json['skuName'],
      price: json['price'],
      validity: json['validity'],
      lifetime: json['lifetime'],
      stripePriceId: json['stripePriceId'],
      skuCode: json['skuCode'],
    );
  }
}