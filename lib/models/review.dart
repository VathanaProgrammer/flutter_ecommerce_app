class Review {
  final int id;
  final int userId;
  final int productId;
  final int? transactionId;
  final int rating;
  final String? title;
  final String? comment;
  final List<String>? images;
  final int helpfulCount;
  final bool verifiedPurchase;
  final bool isApproved;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final String? userName;
  final String? userImage;

  Review({
    required this.id,
    required this.userId,
    required this.productId,
    this.transactionId,
    required this.rating,
    this.title,
    this.comment,
    this.images,
    required this.helpfulCount,
    required this.verifiedPurchase,
    required this.isApproved,
    this.approvedAt,
    required this.createdAt,
    this.userName,
    this.userImage,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      transactionId: json['transaction_id'],
      rating: json['rating'],
      title: json['title'],
      comment: json['comment'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      helpfulCount: json['helpful_count'] ?? 0,
      verifiedPurchase: json['verified_purchase'] ?? false,
      isApproved: json['is_approved'] ?? true,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      userName: json['user']?['name'],
      userImage: json['user']?['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'rating': rating,
      'title': title,
      'comment': comment,
      'images': images,
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${difference.inDays >= 730 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays >= 60 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
