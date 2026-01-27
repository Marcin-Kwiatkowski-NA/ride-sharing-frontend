class Ride {
  final int? id;
  final Driver? driver;
  final City origin;
  final City destination;
  final DateTime departureTime;
  final int availableSeats;
  final double? pricePerSeat;
  final Vehicle? vehicle;
  final RideStatus rideStatus;
  final DateTime? lastModified;
  final List<Driver> passengers;

  Ride({
    this.id,
    this.driver,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.availableSeats,
    this.pricePerSeat,
    this.vehicle,
    RideStatus? rideStatus,
    this.lastModified,
    List<Driver>? passengers,
  })  : rideStatus = rideStatus ?? RideStatus.OPEN,
        passengers = passengers ?? [];

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'] as int?,
      driver: json['driver'] != null ? Driver.fromJson(json['driver']) : null,
      origin: City.fromJson(json['origin']),
      destination: City.fromJson(json['destination']),
      departureTime: DateTime.parse(json['departureTime']),
      availableSeats: json['availableSeats'] as int,
      pricePerSeat: (json['pricePerSeat'] as num?)?.toDouble(),
      vehicle: json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
      rideStatus: RideStatus.values.firstWhere(
        (e) => e.name == json['rideStatus'],
        orElse: () => RideStatus.OPEN,
      ),
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'])
          : null,
      passengers: (json['passengers'] as List<dynamic>?)
              ?.map((p) => Driver.fromJson(p))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver': driver?.toJson(),
      'origin': origin.toJson(),
      'destination': destination.toJson(),
      'departureTime': departureTime.toIso8601String(),
      'availableSeats': availableSeats,
      'pricePerSeat': pricePerSeat,
      'vehicle': vehicle?.toJson(),
      'rideStatus': rideStatus.name,
      'lastModified': lastModified?.toIso8601String(),
      'passengers': passengers.map((p) => p.toJson()).toList(),
    };
  }
}

enum RideStatus {
  OPEN,
  FULL,
  COMPLETED,
  CANCELLED,
}

class City {
  final int? osmId;
  final String name;

  City({this.osmId, required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      osmId: json['osmId'] as int?,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'osmId': osmId, 'name': name};
}

class Driver {
  final int? id;
  final String? username;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final double? rating;
  final int? completedRides;

  Driver({
    this.id,
    this.username,
    this.name,
    this.email,
    this.phoneNumber,
    this.rating,
    this.completedRides,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as int?,
      username: json['username'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      completedRides: (json['completedRides'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'rating': rating,
        'completedRides': completedRides,
      };
}

class Vehicle {
  final int? id;
  final String? make;
  final String? model;
  final int? productionYear;
  final String? color;
  final String? licensePlate;

  Vehicle({
    this.id,
    this.make,
    this.model,
    this.productionYear,
    this.color,
    this.licensePlate,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as int?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      productionYear: (json['productionYear'] as num?)?.toInt(),
      color: json['color'] as String?,
      licensePlate: json['licensePlate'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'make': make,
        'model': model,
        'productionYear': productionYear,
        'color': color,
        'licensePlate': licensePlate,
      };
}
