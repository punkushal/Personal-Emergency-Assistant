class UserProfile {
  final String id;
  final String name;
  final String bloodGroup;
  final String allergies;
  final String medicalConditions;
  final String medications;

  UserProfile({
    required this.id,
    required this.name,
    required this.bloodGroup,
    this.allergies = '',
    this.medicalConditions = '',
    this.medications = '',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      bloodGroup: json['bloodGroup'] as String,
      allergies: json['allergies'] as String,
      medicalConditions: json['medicalConditions'] as String,
      medications: json['medications'] as String,
    );
  }

  //Convert to json for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
      'medications': medications,
    };
  }

  // Create a copy with potentially modified fields
  UserProfile copyWith({
    String? name,
    String? bloodGroup,
    String? allergies,
    String? medicalConditions,
    String? medications,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      medications: medications ?? this.medications,
    );
  }
}
