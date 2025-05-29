import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_emergency_assistant/constants/app_constants.dart';
import 'package:personal_emergency_assistant/providers/user_provider.dart';
import 'package:personal_emergency_assistant/services/storage_service.dart';

// StateNotifier for app settings
class SettingsNotifier extends StateNotifier<Map<String, dynamic>> {
  final StorageService _storageService;

  SettingsNotifier(this._storageService)
    : super({'smsTemplate': AppConstants.defaultSosTemplate}) {
    // Load settings when initialized
    _loadSettings();
  }

  // Load settings from storage
  Future<void> _loadSettings() async {
    final smsTemplate = _storageService.getSmsTemplate();

    state = {...state, 'smsTemplate': smsTemplate};
  }

  // Update SOS message template
  Future<bool> updateSmsTemplate(String template) async {
    final result = await _storageService.setSmsTemplate(template);

    if (result) {
      state = {...state, 'smsTemplate': template};
    }

    return result;
  }

  // Reset app data
  Future<bool> resetAppData() async {
    final result = await _storageService.resetAllData();

    // If reset successful, restore defaults
    if (result) {
      state = {'smsTemplate': AppConstants.defaultSosTemplate};

      // Set onboarding to false
      await _storageService.setHasCompletedOnboarding(false);
    }

    return result;
  }
}

// Provider for the SettingsNotifier
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Map<String, dynamic>>((ref) {
      final storageService = ref.watch(storageServiceProvider);
      return SettingsNotifier(storageService);
    });
