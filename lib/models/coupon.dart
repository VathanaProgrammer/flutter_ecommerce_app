class Coupon {
  final int id;
  final String code;
  final String type; // 'percentage' or 'fixed'
  final double value;
  final double? minPurchaseAmount;
  final double? maxDiscountAmount;
  final int? usageLimit;
  final int usedCount;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final bool isActive;
  final String? description;

  Coupon({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.minPurchaseAmount,
    this.maxDiscountAmount,
    this.usageLimit,
    required this.usedCount,
    this.validFrom,
    this.validUntil,
    required this.isActive,
    this.description,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      code: json['code'],
      type: json['type'],
      value: (json['value'] as num).toDouble(),
      minPurchaseAmount: json['min_purchase_amount'] != null
          ? (json['min_purchase_amount'] as num).toDouble()
          : null,
      maxDiscountAmount: json['max_discount_amount'] != null
          ? (json['max_discount_amount'] as num).toDouble()
          : null,
      usageLimit: json['usage_limit'],
      usedCount: json['used_count'] ?? 0,
      validFrom: json['valid_from'] != null
          ? DateTime.parse(json['valid_from'])
          : null,
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'])
          : null,
      isActive: json['is_active'] ?? true,
      description: json['description'],
    );
  }

  bool get isValid {
    if (!isActive) return false;
    final now = DateTime.now();
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    if (usageLimit != null && usedCount >= usageLimit!) return false;
    return true;
  }

  double calculateDiscount(double subtotal) {
    if (!isValid) return 0;
    if (minPurchaseAmount != null && subtotal < minPurchaseAmount!) return 0;

    double discount = 0;
    if (type == 'percentage') {
      discount = (subtotal * value) / 100;
    } else {
      discount = value;
    }

    if (maxDiscountAmount != null && discount > maxDiscountAmount!) {
      discount = maxDiscountAmount!;
    }

    return discount;
  }
}
