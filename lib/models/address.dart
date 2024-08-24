class Address {
  final String placeName;
  final double latitude;
  final double longitude;
  final String placeId;
  final String placeFormatedAddress;

  Address(
      {required this.placeName,
      required this.latitude,
      required this.longitude,
      required this.placeId,
      required this.placeFormatedAddress});
}
