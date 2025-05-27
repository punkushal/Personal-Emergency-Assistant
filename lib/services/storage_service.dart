import 'dart:convert';
import 'dart:developer';

import 'package:personal_emergency_assistant/constants/app_constants.dart';
import 'package:personal_emergency_assistant/models/emergency_contact.dart';
import 'package:personal_emergency_assistant/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  late SharedPreferences _prefs;

  //Initialize the shared preferences instance
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  //User profile methods
  Future<bool> saveUserProfile(UserProfile profile) async {
    final profileJson = jsonEncode(profile.toJson());
    return await _prefs.setString(
      AppConstants.prefsUserProfileKey,
      profileJson,
    );
  }

  UserProfile? getUserProfile() {
    final profileJson = _prefs.getString(AppConstants.prefsUserProfileKey);
    if (profileJson == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(profileJson));
    } catch (e) {
      log('Error parsing user profile : $e');
      return null;
    }
  }

  //Emergency Contacts Methods
  Future<bool> saveEmergencyContacts(List<EmergencyContact> contacts) async {
    final contactJson = jsonEncode(
      contacts.map((contact) => contact.toJson()).toList(),
    );
    return await _prefs.setString(
      AppConstants.prefsEmergencyContactsKey,
      contactJson,
    );
  }

  List<EmergencyContact> getEmergencyContacts() {
    final contactsJson = _prefs.getString(
      AppConstants.prefsEmergencyContactsKey,
    );
    if (contactsJson == null) return [];

    try {
      final List<dynamic> decodedList = jsonDecode(contactsJson);
      return decodedList
          .map((item) => EmergencyContact.fromJson(item))
          .toList();
    } catch (e) {
      log('Error parsing emergency contacts: $e');
      return [];
    }
  }

  // Onboarding Status
  Future<bool> setHasCompletedOnboarding(bool completed) async {
    return await _prefs.setBool(
      AppConstants.prefsHasCompletedOnboardingKey,
      completed,
    );
  }

  bool getHasCompletedOnboarding() {
    return _prefs.getBool(AppConstants.prefsHasCompletedOnboardingKey) ?? false;
  }

  // SOS Message Template
  Future<bool> setSmsTemplate(String template) async {
    return await _prefs.setString(AppConstants.prefsSmsTemplateKey, template);
  }

  String getSmsTemplate() {
    return _prefs.getString(AppConstants.prefsSmsTemplateKey) ??
        AppConstants.defaultSosTemplate;
  }

  // Reset all data (for testing or user reset)
  Future<bool> resetAllData() async {
    return await _prefs.clear();
  }
}
