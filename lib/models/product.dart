class Product {
  final int id;
  final String name;
  final double price;
  final String? image_url;
  final String? category;
  final Discount? discount;
  final String? sku;
  final Map<String, String>?
  attributes; // Add this - stores "Color": "Red", "Size": "M"
  bool? isFavorite; // ← add this
  bool? isFeatured;
  bool? isRecommended;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.image_url,
    this.discount,
    required this.category,
    this.sku,
    this.attributes,
    this.isFavorite,
    this.isFeatured,
    this.isRecommended,
  });

  double get finalPrice {
    if (discount == null) return price;

    if (discount!.isPercentage) {
      return price - (price * discount!.value / 100);
    } else {
      return price - discount!.value;
    }
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: (json['price'] as num).toDouble(),
      image_url: json['image_url'],
      discount: json['discount'] != null
          ? Discount.fromJson(json['discount'])
          : null,
      sku: json['sku'],
      attributes: json['attributes'] != null
          ? Map<String, String>.from(json['attributes'])
          : null,
      isFavorite: json['is_favorite'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      isRecommended: json['is_recommended'] ?? false,
    );
  }
}

class Discount {
  final int id;
  final double value;
  final bool isPercentage;

  Discount({required this.id, required this.value, required this.isPercentage});

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id'],
      value: double.tryParse(json['value']?.toString() ?? '0') ?? 0,
      isPercentage: json['is_percentage'] == 1 || json['is_percentage'] == true,
    );
  }
}
