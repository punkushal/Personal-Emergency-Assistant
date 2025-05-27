import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:personal_emergency_assistant/constants/app_constants.dart';
import 'package:personal_emergency_assistant/models/first_aid_guide.dart';

class FirstAidService {
  // Load first aid guides from asset
  Future<List<FirstAidGuide>> loadFirstAidGuides() async {
    try {
      final String jsonString = await rootBundle.loadString(
        AppConstants.firstAidGuidesPath,
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      return jsonList.map((json) => FirstAidGuide.fromJson(json)).toList();
    } catch (e) {
      log('Error loading first aid guides: $e');
      return [];
    }
  }

  // Search guides by query
  List<FirstAidGuide> searchGuides(List<FirstAidGuide> guides, String query) {
    if (query.isEmpty) return guides;

    final lowerQuery = query.toLowerCase();

    return guides.where((guide) {
      return guide.title.toLowerCase().contains(lowerQuery) ||
          guide.category.toLowerCase().contains(lowerQuery) ||
          guide.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
          guide.steps.any(
            (step) => step.desc.toLowerCase().contains(lowerQuery),
          );
    }).toList();
  }

  // Get guides by category
  List<FirstAidGuide> getGuidesByCategory(
    List<FirstAidGuide> guides,
    String category,
  ) {
    if (category.isEmpty) return guides;

    return guides.where((guide) => guide.category == category).toList();
  }

  // Get all unique categories
  List<String> getAllCategories(List<FirstAidGuide> guides) {
    final categories = guides.map((guide) => guide.category).toSet().toList();
    categories.sort();
    return categories;
  }
}
