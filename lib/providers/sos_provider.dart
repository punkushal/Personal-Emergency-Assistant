import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_emergency_assistant/providers/alerts_provider.dart';
import 'package:personal_emergency_assistant/providers/contacts_provider.dart'
    show emergencyContactsProvider;
import 'package:personal_emergency_assistant/providers/user_provider.dart';
import 'package:personal_emergency_assistant/services/sms_service.dart';

import '../models/emergency_contact.dart';
import '../models/user_profile.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';

enum SosStatus { idle, sending, sent, error }

class SosState {
  final SosStatus status;
  final String? errMsg;
  final List<String>? sentTo;

  SosState({this.status = SosStatus.idle, this.errMsg, this.sentTo});

  SosState copyWith({
    SosStatus? status,
    String? errorMessage,
    List<String>? sentTo,
  }) {
    return SosState(
      status: status ?? this.status,
      errMsg: errorMessage ?? errMsg,
      sentTo: sentTo ?? this.sentTo,
    );
  }
}

//Provider for the SmsService
final smsServiceProvider = Provider<SmsService>((ref) {
  return SmsService();
});

//StateNotifier for SOS functionality
class SosNotifier extends StateNotifier<SosState> {
  final SmsService _smsService;
  final LocationService _locationService;
  final StorageService _storageService;
  final UserProfile? _userProfile;
  final List<EmergencyContact> _contacts;

  SosNotifier(
    this._smsService,
    this._locationService,
    this._storageService,
    this._userProfile,
    this._contacts,
  ) : super(SosState());

  //Send SOS message
  Future<void> sendSosMessage() async {
    try {
      //Update state to sending
      state = state.copyWith(status: SosStatus.sending);

      //Get location
      final locationResult = await _locationService.getCurrentLocation();
      final locationString = locationResult.addressString;

      //Get SMS template
      final smsTemplate = _storageService.getSmsTemplate();

      //Send SOS message
      final result = await _smsService.sendSosMsg(
        contacts: _contacts,
        messageTemplate: await smsTemplate,
        userProfile: _userProfile,
        locationString: locationString,
      );

      if (result.success) {
        //Update state to sent
        state = state.copyWith(
          status: SosStatus.sent,
          sentTo: result.sentTo,
          errorMessage: null,
        );
      } else {
        // Update state with error
        state = state.copyWith(
          status: SosStatus.error,
          errorMessage: result.errorMessage ?? 'Failed to send SOS message',
        );
      }
    } catch (e) {
      // Update state with error
      state = state.copyWith(
        status: SosStatus.error,
        errorMessage: 'Error sending SOS message: $e',
      );
    }
  }

  // Reset SOS state
  void resetSosState() {
    state = SosState();
  }
}

//Provider for the SosNotifier
final sosProvider = StateNotifierProvider<SosNotifier, SosState>((ref) {
  final smsService = ref.watch(smsServiceProvider);
  final locationService = ref.watch(locationServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  final userProfile = ref.watch(userProfileProvider);
  final contacts = ref.watch(emergencyContactsProvider);

  return SosNotifier(
    smsService,
    locationService,
    storageService,
    userProfile,
    contacts,
  );
});
