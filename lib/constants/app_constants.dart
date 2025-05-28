class AppConstants {
  //API Endpoints
  static const String weatherApiBaseUrl =
      'https://api.openweathermap.org/data/2.5/weather?';

  //Default SOS message template
  static const String defaultSosTemplate =
      'Emergency: I need help! My location is: {LOCATION}, Medical info: Blood type: {BLOOD_TYPE}, Allergies: ALLERGIES}';

  //Permission messages
  static const String locationPermissionRationale =
      "Your location is needed to send accurate emergency alerts";
  static const String smsPermissionRationale =
      'SMS permissioin is needed to send emergency messages';
  static const String contactsPermissionRationale =
      'Contacts permission is needed to select emergency contacts';

  //First Aid Guide Asset path
  static const String firstAidGuidesPath = 'assets/data/first_aid_guides.json';

  //Shared preferences keys
  static const String prefsUserProfileKey = 'user_profile';
  static const String prefsEmergencyContactsKey = 'emergency_contacts';
  static const String prefsHasCompletedOnboardingKey =
      'has_completed_onboarding';
  static const String prefsSmsTemplateKey = 'sms_templated';
}
