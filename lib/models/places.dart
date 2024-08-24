import 'dart:convert';

class Place {
  final String placeId;
  final String mainText;
  final String secondaryText;

  Place({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });

  factory Place.fromMap(Map<String, dynamic> map) {
    return Place(
      placeId: map['place_id'] as String,
      mainText: (map['structured_formatting']['main_text'] as String?) ?? 'Unknown Place',
      secondaryText: (map['structured_formatting']['secondary_text'] as String?) ?? '',
    );
  }

  factory Place.fromJson(String source) =>
      Place.fromMap(json.decode(source) as Map<String, dynamic>);
}
