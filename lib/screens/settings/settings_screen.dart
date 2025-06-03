import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_emergency_assistant/constants/app_strings.dart';
import 'package:personal_emergency_assistant/constants/app_themes.dart';
import 'package:personal_emergency_assistant/providers/user_provider.dart';
import 'package:personal_emergency_assistant/providers/contacts_provider.dart';
import 'package:personal_emergency_assistant/providers/settings_provider.dart';
import 'package:personal_emergency_assistant/screens/settings/contact_management.dart';
import 'package:personal_emergency_assistant/screens/onboarding/onboarding_screen.dart';
import 'package:personal_emergency_assistant/screens/settings/profile_management.dart';
import 'package:personal_emergency_assistant/widgets/custom_txt_field.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _smsTemplateController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsProvider);
      _smsTemplateController.text = settings['smsTemplate'] ?? '';
    });
  }

  @override
  void dispose() {
    _smsTemplateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final contacts = ref.watch(emergencyContactsProvider);
    ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settingsTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildSectionHeader(AppStrings.profileSection),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    userProfile?.name.isNotEmpty == true
                        ? userProfile!.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(userProfile?.name ?? 'Not set'),
                subtitle:
                    userProfile != null
                        ? Text('Blood Type: ${userProfile.bloodGroup}')
                        : const Text('Profile not completed'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileManagement(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Emergency Contacts Section
            _buildSectionHeader(AppStrings.contactsSection),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.contacts),
                    title: const Text('Emergency Contacts'),
                    subtitle: Text(
                      '${contacts.length} contact${contacts.length != 1 ? 's' : ''} added',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ContactManagement(),
                        ),
                      );
                    },
                  ),

                  if (contacts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: Colors.orange[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Add at least one emergency contact to use SOS alerts',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SOS Message Template Section
            _buildSectionHeader(AppStrings.templateSection),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'SOS Message Template',
                          style: AppThemes.subheadingStyle.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = !_isEditing;
                            });
                            if (!_isEditing) {
                              _saveSmsTemplate();
                            }
                          },
                          child: Text(_isEditing ? 'Save' : 'Edit'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    CustomTxtField(
                      controller: _smsTemplateController,
                      maxLines: 4,
                      readOnly: !_isEditing,
                      labelText: 'Message Template',
                      helperText:
                          'Use {LOCATION}, {BLOOD_TYPE}, {ALLERGIES}, {NAME} as placeholders',
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available Placeholders:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• {LOCATION} - Your current location\n'
                            '• {NAME} - Your name\n'
                            '• {BLOOD_TYPE} - Your blood group\n'
                            '• {ALLERGIES} - Your allergies',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // App Settings Section
            _buildSectionHeader('App Settings'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showHelpDialog();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showAboutDialog();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.refresh, color: Colors.orange[700]),
                    title: Text(
                      'Reset App Data',
                      style: TextStyle(color: Colors.orange[700]),
                    ),
                    onTap: () {
                      _showResetConfirmationDialog();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: AppThemes.subheadingStyle.copyWith(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Future<void> _saveSmsTemplate() async {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final success = await settingsNotifier.updateSmsTemplate(
      _smsTemplateController.text,
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SMS template updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update SMS template'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Help & Support'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Emergency Features:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• SOS Button: Sends emergency alerts to your contacts with your location',
                  ),
                  Text(
                    '• Emergency Info: Displays your medical information for first responders',
                  ),
                  Text(
                    '• First Aid Guides: Access offline medical emergency procedures',
                  ),
                  Text(
                    '• Alert Feed: Get real-time emergency notifications for your area',
                  ),
                  SizedBox(height: 16),
                  Text('Setup:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• Complete your profile with medical information'),
                  Text('• Add emergency contacts who will receive SOS alerts'),
                  Text('• Customize your SOS message template'),
                  Text('• Review and practice first aid procedures'),
                  SizedBox(height: 16),
                  Text(
                    'Permissions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Location: Required for accurate emergency location sharing',
                  ),
                  Text('• SMS: Required to send emergency text messages'),
                  Text(
                    '• Contacts: Optional, for easier emergency contact selection',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('About Emergency Assistant'),
            content: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Personal Emergency Assistant',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Version 1.0.0'),
                SizedBox(height: 16),
                Text(
                  'Your personal safety companion that helps you in emergency situations with:',
                ),
                SizedBox(height: 8),
                Text('• Quick SOS alerts with location sharing'),
                Text('• Comprehensive first-aid guides'),
                Text('• Real-time emergency notifications'),
                Text('• Emergency medical information display'),
                SizedBox(height: 16),
                Text(
                  'This app is designed to provide assistance during emergencies but should not replace professional emergency services.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset App Data'),
            content: const Text(
              'This will delete all your data including profile, contacts, and settings. You will need to set up the app again. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _resetAppData();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }

  Future<void> _resetAppData() async {
    try {
      final settingsNotifier = ref.read(settingsProvider.notifier);
      final success = await settingsNotifier.resetAppData();

      if (success) {
        // Navigate back to onboarding
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to reset app data'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting app data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
