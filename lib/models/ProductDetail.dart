// models/product_detail.dart

class ProductDetail {
  final int id;
  final String name;
  final String? imageUrl;
  final int categoryId;
  final String categoryName;
  final List<String> descriptionLines;
  final List<ProductVariant> variants;
  final List<AttributeGroup> attributeGroups;

  ProductDetail({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.categoryId,
    required this.categoryName,
    required this.descriptionLines,
    required this.variants,
    required this.attributeGroups,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      categoryId: json['category_id'],
      categoryName: json['category_name'] ?? '',
      descriptionLines: (json['description_lines'] as List?)
          ?.map((e) => e['text'] as String)
          .toList() ?? [],
      variants: (json['variants'] as List?)
          ?.map((e) => ProductVariant.fromJson(e))
          .toList() ?? [],
      attributeGroups: _groupAttributes(json['variants'] as List?),
    );
  }

  static List<AttributeGroup> _groupAttributes(List? variants) {
    if (variants == null || variants.isEmpty) return [];
    
    Map<String, Set<String>> attributeMap = {};
    
    for (var variant in variants) {
      if (variant['attributes'] != null) {
        for (var attr in variant['attributes']) {
          final attrName = attr['attribute_name'] as String;
          final attrValue = attr['value'] as String;
          
          if (!attributeMap.containsKey(attrName)) {
            attributeMap[attrName] = {};
          }
          attributeMap[attrName]!.add(attrValue);
        }
      }
    }
    
    return attributeMap.entries.map((e) => AttributeGroup(
      name: e.key,
      values: e.value.toList(),
    )).toList();
  }
}

class ProductVariant {
  final int id;
  final int productId;
  final String? sku;
  final double price;
  final List<VariantAttribute> attributes;
  final ProductDiscount? discount;

  ProductVariant({
    required this.id,
    required this.productId,
    this.sku,
    required this.price,
    required this.attributes,
    this.discount,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'],
      productId: json['product_id'],
      sku: json['sku'],
      price: double.parse(json['price'].toString()),
      attributes: (json['attributes'] as List?)
          ?.map((e) => VariantAttribute.fromJson(e))
          .toList() ?? [],
      discount: json['discount'] != null 
          ? ProductDiscount.fromJson(json['discount']) 
          : null,
    );
  }

  double get finalPrice {
    if (discount == null || !discount!.active) return price;
    
    if (discount!.isPercentage) {
      return price - (price * discount!.value / 100);
    } else {
      return price - discount!.value;
    }
  }

  String get displayPrice {
    if (discount != null && discount!.active) {
      return '\$${finalPrice.toStringAsFixed(2)}';
    }
    return '\$${price.toStringAsFixed(2)}';
  }
}

class VariantAttribute {
  final int id;
  final String attributeName;
  final String value;

  VariantAttribute({
    required this.id,
    required this.attributeName,
    required this.value,
  });

  factory VariantAttribute.fromJson(Map<String, dynamic> json) {
    return VariantAttribute(
      id: json['attribute_value_id'],
      attributeName: json['attribute_name'],
      value: json['value'],
    );
  }
}

class AttributeGroup {
  final String name;
  final List<String> values;

  AttributeGroup({
    required this.name,
    required this.values,
  });
}

class ProductDiscount {
  final int id;
  final String name;
  final double value;
  final bool isPercentage;
  final bool active;

  ProductDiscount({
    required this.id,
    required this.name,
    required this.value,
    required this.isPercentage,
    required this.active,
  });

  factory ProductDiscount.fromJson(Map<String, dynamic> json) {
    return ProductDiscount(
      id: json['id'],
      name: json['name'],
      value: double.parse(json['value'].toString()),
      isPercentage: json['is_percentage'] == 1 || json['is_percentage'] == true,
      active: json['active'] == 1 || json['active'] == true,
    );
  }

  String get displayDiscount {
    if (isPercentage) {
      return '${value.toStringAsFixed(0)}% OFF';
    } else {
      return '\$${value.toStringAsFixed(2)} OFF';
    }
  }
}