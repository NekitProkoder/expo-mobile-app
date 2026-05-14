class Exhibitor {
  final int id;
  final String name;
  final String? description;
  final String? category;
  final String? standNumber;
  final String? country;
  final String? city;
  final String? website;
  final String? phone;
  final String? email;
  final String? logoUrl;

  Exhibitor({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.standNumber,
    this.country,
    this.city,
    this.website,
    this.phone,
    this.email,
    this.logoUrl,
  });

  factory Exhibitor.fromJson(Map<String, dynamic> json) {
    return Exhibitor(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      standNumber: json['stand_number'],
      country: json['country'],
      city: json['city'],
      website: json['website'],
      phone: json['phone'],
      email: json['email'],
      logoUrl: json['logo_url'],
    );
  }
}