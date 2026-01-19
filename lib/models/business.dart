class Business {
  final int id;
  final String name;
  final String? logo;

  Business({required this.id, required this.name, this.logo});

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'],
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
    );
  }
}
