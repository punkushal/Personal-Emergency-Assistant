import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_emergency_assistant/models/emergency_contact.dart';
import 'package:personal_emergency_assistant/services/storage_service.dart';
import 'package:uuid/uuid.dart';

//StateNotifier for emergency contacts
class EmergencyContactsNotifier extends StateNotifier<List<EmergencyContact>> {
  final StorageService _storageService = StorageService.instance;
  EmergencyContactsNotifier() : super([]) {
    //Load contacts when initialized
    _loadContacts();
  }

  // Load contacts from storage
  Future<void> _loadContacts() async {
    final contacts = await _storageService.getEmergencyContacts();
    state = contacts;
  }

  // Add a new emergency contact
  Future<bool> addContact({
    required String name,
    required String phoneNumber,
    String relationship = '',
    bool isPrimary = false,
  }) async {
    // If this is the first contact or explicitly set to primary, make it primary
    final shouldBePrimary = isPrimary || state.isEmpty;

    // If this will be primary, make sure others are not
    List<EmergencyContact> updatedContacts =
        shouldBePrimary
            ? state
                .map((contact) => contact.copyWith(isPrimary: false))
                .toList()
            : List.from(state);

    // Create the new contact
    final newContact = EmergencyContact(
      id: const Uuid().v4(),
      name: name,
      phoneNumber: phoneNumber,
      relationship: relationship,
      isPrimary: shouldBePrimary,
    );

    // Add to the list
    updatedContacts.add(newContact);

    // Save to storage
    final result = await _storageService.saveEmergencyContacts(updatedContacts);

    if (result) {
      state = updatedContacts;
    }

    return result;
  }

  //Update an existing contact
  Future<bool> updateContact({
    required String id,
    String? name,
    String? phoneNumber,
    String? relationship,
    bool? isPrimary,
  }) async {
    //Find the contact index
    final index = state.indexWhere((contact) => contact.id == id);
    if (index == -1) return false;

    //Prepare the updated list
    List<EmergencyContact> updatedContacts = List.from(state);

    //If this will be set as primary, make sure others are not
    if (isPrimary == true) {
      updatedContacts =
          updatedContacts
              .map(
                (contact) =>
                    contact.id != id
                        ? contact.copyWith(isPrimary: false)
                        : contact,
              )
              .toList();
    }

    //Update the specific contact
    updatedContacts[index] = updatedContacts[index].copyWith(
      name: name,
      phoneNumber: phoneNumber,
      relationship: relationship,
      isPrimary: isPrimary,
    );

    //Save to storage
    final result = await _storageService.saveEmergencyContacts(updatedContacts);

    if (result) {
      state = updatedContacts;
    }
    return result;
  }

  //Remove a contact
  Future<bool> removeContact(String id) async {
    final updatedContacts = state.where((contact) => contact.id != id).toList();

    // If we're removing the primary contact and there are other contacts,
    // make the first one primary
    if (updatedContacts.isNotEmpty &&
        !updatedContacts.any((contact) => contact.isPrimary)) {
      updatedContacts[0] = updatedContacts[0].copyWith(isPrimary: true);
    }

    // Save to storage
    final result = await _storageService.saveEmergencyContacts(updatedContacts);

    if (result) {
      state = updatedContacts;
    }

    return result;
  }

  // Get the primary contact
  EmergencyContact? getPrimaryContact() {
    return state.firstWhere(
      (contact) => contact.isPrimary,
      orElse: () => state.first,
    );
  }
}

// Provider for the EmergencyContactsNotifier
final emergencyContactsProvider =
    StateNotifierProvider<EmergencyContactsNotifier, List<EmergencyContact>>((
      ref,
    ) {
      return EmergencyContactsNotifier();
    });
