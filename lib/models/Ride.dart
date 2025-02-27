class Ride {
  final int? id;
  final String? driver;
   String origin;
   String destination;
   DateTime departureTime;
   int availableSeats;
   double pricePerSeat;
   String? vehicle;
   RideStatus rideStatus;
   DateTime? lastModified;
   List<String> passengers;

  Ride({
    this.id,
    this.driver,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.availableSeats,
    required this.pricePerSeat,
    // this.vehicle,
    RideStatus? rideStatus,
    // this.lastModified,
    List<String>? passengers,
  })  : rideStatus = rideStatus ?? RideStatus.OPEN,
        passengers = passengers ?? [];
}

enum RideStatus {
  OPEN,
  FULL,
  COMPLETED,
  CANCELLED,
}
