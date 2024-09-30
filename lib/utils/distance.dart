import 'dart:math';

double calcDist(double lat1, double long1, double lat2, double long2) {
  const double earthRadiusKm = 6371.0;

  double degToRad(double degrees) => degrees * (pi / 180);

  final double lat1Rad = degToRad(lat1);
  final double lon1Rad = degToRad(long1);
  final double lat2Rad = degToRad(lat2);
  final double lon2Rad = degToRad(long2);

  final double dLat = lat2Rad - lat1Rad;
  final double dLon = lon2Rad - lon1Rad;

  final double a = pow(sin(dLat / 2), 2) +
      cos(lat1Rad) * cos(lat2Rad) * pow(sin(dLon / 2), 2);
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadiusKm * c;
}
