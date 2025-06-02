import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_emergency_assistant/models/user_profile.dart';
import 'package:personal_emergency_assistant/services/storage_service.dart';
import 'package:uuid/uuid.dart';

//Provider for the Storage service
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

//StateNotifier for userprofile
class UserProfileNotifier extends StateNotifier<UserProfile?> {
  final StorageService _storageService;
  UserProfileNotifier(this._storageService) : super(null) {
    //Load the user profile when initialzed
    _loadUserProfile();
  }

  //Load the user profile from storage
  Future<void> _loadUserProfile() async {
    final profile = _storageService.getUserProfile();
    state = await profile;
  }

  //Save a new user profile
  Future<bool> saveUserProfile({
    required String name,
    required String bloodGroup,
    String allergies = '',
    String medications = '',
    String medicalConditions = '',
  }) async {
    //Create a new profile or update existing one
    final newProfile =
        state == null
            ? UserProfile(
              id: const Uuid().v4(),
              name: name,
              bloodGroup: bloodGroup,
              medicalConditions: medicalConditions,
              medications: medications,
            )
            : state!.copyWith(
              name: name,
              bloodGroup: bloodGroup,
              allergies: allergies,
              medicalConditions: medicalConditions,
              medications: medications,
            );

    //Save to storage
    final result = await _storageService.saveUserProfile(newProfile);

    if (result) {
      state = newProfile;
    }
    return result;
  }

  //Reset the user profile
  Future<bool> resetUserProfile() async {
    state = null;
    return true;
  }
}

//Provider for the UserProfileNotifier
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
      final storageService = ref.watch(storageServiceProvider);
      return UserProfileNotifier(storageService);
    });
