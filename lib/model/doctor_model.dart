// lib/model/doctor_model.dart

class Doctor {
  final String name;
  final String region;
  final double rating;
  final String experience;
  final String pastWorks;
  final String awards;
  final String visitingHours;
  final String imagePath;

  Doctor({
    required this.name,
    required this.region,
    required this.rating,
    required this.experience,
    required this.pastWorks,
    required this.awards,
    required this.visitingHours,
    required this.imagePath,
  });
}
