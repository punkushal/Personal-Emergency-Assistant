import 'package:flutter_sms/flutter_sms.dart';
import 'package:personal_emergency_assistant/models/emergency_contact.dart';
import 'package:personal_emergency_assistant/models/user_profile.dart';
import 'package:permission_handler/permission_handler.dart' as permission;

class SmsService {
  //Send sos message to emergency contacts
  Future<SmsResult> sendSosMsg({
    required List<EmergencyContact> contacts,
    required String messageTemplate,
    required UserProfile? userProfile,
    required String? locationString,
  }) async {
    try {
      //Check if we have the sos permission
      final permissionStatus = permission.Permission.sms.status;

      if (await permissionStatus.isDenied) {
        //Request permission
        final requestResult = await permission.Permission.sms.request();
        if (requestResult.isDenied || requestResult.isPermanentlyDenied) {
          return SmsResult(
            success: false,
            errorMessage: 'SMS permission denied',
          );
        }
      }

      //Make sure we have contacts
      if (contacts.isEmpty) {
        return SmsResult(
          success: false,
          errorMessage: 'No emergency contacts found',
        );
      }

      //Extract phone numbers
      final List<String> phoneNumbers =
          contacts.map((contact) => contact.phoneNumber).toList();

      //Prepare the message with placeholders replaced
      String message = messageTemplate;

      //Replace placeholders with actual data
      if (userProfile != null) {
        message = message.replaceAll('{BLOOD_TYPE}', userProfile.bloodGroup);
        message = message.replaceAll(
          '{ALLERGIES}',
          userProfile.allergies.isEmpty ? 'None' : userProfile.allergies,
        );
        message = message.replaceAll('{NAME}', userProfile.name);
      }

      if (locationString != null) {
        message = message.replaceAll('{LOCATION}', locationString);
      } else {
        message = message.replaceAll('{LOCATION}', 'Location unavailable');
      }

      //Send the message
      await sendSMS(
        message: message,
        recipients: phoneNumbers,
        sendDirect: true,
      );

      return SmsResult(success: true, sentTo: phoneNumbers);
    } catch (e) {
      return SmsResult(success: false, errorMessage: 'Error sending SMS: $e');
    }
  }

  // Check SMS permission status
  Future<permission.PermissionStatus> getSmsPermission() async {
    return await permission.Permission.sms.status;
  }
}

class SmsResult {
  final bool success;
  final String? errorMessage;
  final List<String>? sentTo;

  SmsResult({required this.success, this.errorMessage, this.sentTo});
}
