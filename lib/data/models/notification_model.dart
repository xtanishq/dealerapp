class DealerNotification {
  final String id;
  final String title;
  final String? description;
  final String? image;
  final String? category;
  final String? type;
  final String? language;
  final String? location;

  DealerNotification({
    required this.id,
    required this.title,
    this.description,
    this.image,
    this.category,
    this.type,
    this.language,
    this.location,
  });

  factory DealerNotification.fromJson(Map<String, dynamic> json) {
    String? locationStr;
    try {
      final country = json['country'];
      if (country != null) {
        final state = country['state'];
        final district = state?['district'];
        final city = district?['city'];
        
        final cityName = city?['name'];
        final districtName = district?['name'];
        final stateName = state?['name'];
        
        if (cityName != null) {
          locationStr = '$cityName, $districtName, $stateName';
        }
      }
    } catch (e) {
    }
    
    return DealerNotification(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'No Title',
      description: json['description'],
      image: json['image'],
      category: json['category'],
      type: json['type'],
      language: json['language'],
      location: locationStr,
    );
  }
}
