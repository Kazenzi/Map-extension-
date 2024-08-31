class Crime {
  final double latitude;
  final double longitude;
  final String crime;
  final String description;

  Crime({required this.latitude, required this.longitude, required this.crime, required this.description});

  factory Crime.fromJson(Map<String, dynamic> json) {
    return Crime(
      latitude: json['latitude'],
      longitude: json['longitude'],
      crime: json['crime'],
      description: json['description'],
    );
  }
}
