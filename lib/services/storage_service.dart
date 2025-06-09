import 'dart:convert';
import 'dart:developer';

import 'package:personal_emergency_assistant/constants/app_constants.dart';
import 'package:personal_emergency_assistant/models/emergency_contact.dart';
import 'package:personal_emergency_assistant/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  late SharedPreferences _prefs;
  static StorageService? _instance;
  bool _isInitialized = false;

  //Privated constructor
  StorageService._();

  //Singleton instance getter
  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  //Initialize the shared preferences instance
  Future<void> init() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  //Getter to check if initialized
  bool get isInitialized => _isInitialized;

  //Ensure initialization before any operation
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  //User profile methods
  Future<bool> saveUserProfile(UserProfile profile) async {
    await _ensureInitialized();
    final profileJson = jsonEncode(profile.toJson());
    return await _prefs.setString(
      AppConstants.prefsUserProfileKey,
      profileJson,
    );
  }

  Future<UserProfile?> getUserProfile() async {
    await _ensureInitialized();
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
    await _ensureInitialized();
    final contactJson = jsonEncode(
      contacts.map((contact) => contact.toJson()).toList(),
    );
    return await _prefs.setString(
      AppConstants.prefsEmergencyContactsKey,
      contactJson,
    );
  }

  Future<List<EmergencyContact>> getEmergencyContacts() async {
    await _ensureInitialized();
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
    await _ensureInitialized();
    return await _prefs.setBool(
      AppConstants.prefsHasCompletedOnboardingKey,
      completed,
    );
  }

  Future<bool> getHasCompletedOnboarding() async {
    await _ensureInitialized();
    return _prefs.getBool(AppConstants.prefsHasCompletedOnboardingKey) ?? false;
  }

  // SOS Message Template
  Future<bool> setSmsTemplate(String template) async {
    await _ensureInitialized();
    return await _prefs.setString(AppConstants.prefsSmsTemplateKey, template);
  }

  Future<String> getSmsTemplate() async {
    await _ensureInitialized();
    return _prefs.getString(AppConstants.prefsSmsTemplateKey) ??
        AppConstants.defaultSosTemplate;
  }

  // Reset all data (for testing or user reset)
  Future<bool> resetAllData() async {
    await _ensureInitialized();
    return await _prefs.clear();
  }
}
