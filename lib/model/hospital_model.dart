// lib/model/hospital_model.dart

class Hospital {
  final String name;
  final Map<String, List<String>> domainDoctors;
  final double latitude;
  final double longitude;
  final List<String> reviews;

  Hospital({
    required this.name,
    required this.domainDoctors,
    required this.latitude,
    required this.longitude,
    required this.reviews,
  });
}
