class FirstAidGuide {
  final String id;
  final String title;
  final String category;
  final String? imageAsset;
  final bool isEmergency;
  final List<String> tags;
  final List<FirstAidStep> steps;

  FirstAidGuide({
    required this.id,
    required this.title,
    required this.category,
    this.imageAsset = '',
    this.tags = const [],
    this.isEmergency = false,
    required this.steps,
  });

  // Create from JSON for local storage
  factory FirstAidGuide.fromJson(Map<String, dynamic> json) {
    final stepsList =
        (json['steps'] as List<dynamic>)
            .map((step) => FirstAidStep.fromJson(step as Map<String, dynamic>))
            .toList();

    return FirstAidGuide(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      steps: stepsList,
      imageAsset: json['imageAsset'] as String?,
      tags: List<String>.from(json['tags'] as List<dynamic>? ?? []),
      isEmergency: json['isEmergency'] as bool? ?? false,
    );
  }

  // Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'steps': steps.map((step) => step.toJson()).toList(),
      'imageAsset': imageAsset,
      'tags': tags,
      'isEmergency': isEmergency,
    };
  }
}

class FirstAidStep {
  final int order;
  final String desc;
  final String? imageAsset;
  final bool isWarning;

  FirstAidStep({
    required this.order,
    required this.desc,
    this.imageAsset,
    this.isWarning = false,
  });

  // Create from JSON
  factory FirstAidStep.fromJson(Map<String, dynamic> json) {
    return FirstAidStep(
      order: json['order'] as int,
      desc: json['desc'] as String,
      imageAsset: json['imageAsset'] as String?,
      isWarning: json['isWarning'] as bool? ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'desc': desc,
      'imageAsset': imageAsset,
      'isWarning': isWarning,
    };
  }
}
