class Ride {
  final String? id;
  final String? riderName;
  final String? riderPhone;
  final String? pickupAddress;
  final String? destinationAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final String? driverId;
  final String? paymentMethod;
  final DateTime? createdAt;

  Ride({
    this.id,
    this.riderName,
    this.riderPhone,
    this.pickupAddress,
    this.destinationAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
    this.driverId,
    this.paymentMethod,
    this.createdAt,
  });

  // Factory constructor to create a Ride instance from a JSON map
  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['_id'] ?? '', // Handle null values with a default empty string
      riderName: json['riderName'] ?? '',
      riderPhone: json['riderPhone'] ?? '',
      pickupAddress: json['pickupAddress'] ?? '',
      destinationAddress: json['destinationAddress'] ?? '',
      pickupLatitude: json['location']['latitude']?.toDouble() ?? 0.0,
      pickupLongitude: json['location']['longitude']?.toDouble() ?? 0.0,
      destinationLatitude: json['destination']['latitude']?.toDouble() ?? 0.0,
      destinationLongitude: json['destination']['longitude']?.toDouble() ?? 0.0,
      driverId: json['driverId'] ?? '',
      paymentMethod: json['paymentMethod'] ?? 'card', // Default value
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Method to convert a Ride instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      '_id': id ?? '',
      'riderName': riderName ?? '',
      'riderPhone': riderPhone ?? '',
      'pickupAddress': pickupAddress ?? '',
      'destinationAddress': destinationAddress ?? '',
      'location': {
        'latitude': pickupLatitude ?? 0.0,
        'longitude': pickupLongitude ?? 0.0,
      },
      'destination': {
        'latitude': destinationLatitude ?? 0.0,
        'longitude': destinationLongitude ?? 0.0,
      },
      'driverId': driverId ?? '',
      'paymentMethod': paymentMethod ?? 'card',
      'createdAt':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
}
