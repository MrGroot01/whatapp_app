class FoundProfile {
  final String uid;
  final String name;
  final String email;
  final String phone; // digits only, empty for accounts made before phones
  final String countryCode;

  const FoundProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.countryCode,
  });

  bool get hasPhone => phone.isNotEmpty;
}