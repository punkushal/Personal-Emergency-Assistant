import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_emergency_assistant/constants/app_themes.dart';
import 'package:personal_emergency_assistant/providers/contacts_provider.dart';
import 'package:personal_emergency_assistant/widgets/custom_button.dart';
import '../../widgets/custom_txt_field.dart';

class OnboardingContactsForm extends ConsumerStatefulWidget {
  const OnboardingContactsForm({super.key});

  @override
  ConsumerState<OnboardingContactsForm> createState() =>
      _OnboardingContactsFormState();
}

class _OnboardingContactsFormState
    extends ConsumerState<OnboardingContactsForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();

  bool _isAddingContact = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Future<void> _addContact() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both name and phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isAddingContact = true;
    });

    try {
      final contactsNotifier = ref.read(emergencyContactsProvider.notifier);
      final success = await contactsNotifier.addContact(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        relationship: _relationshipController.text.trim(),
        isPrimary: true, // First contact is always primary
      );

      if (success) {
        // Clear the form
        _nameController.clear();
        _phoneController.clear();
        _relationshipController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Emergency contact added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding contact: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isAddingContact = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(emergencyContactsProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            Text('Emergency Contacts', style: AppThemes.headingStyle),

            const SizedBox(height: 8),

            Text(
              'Add at least one emergency contact who will receive your SOS alerts.',
              style: AppThemes.bodyStyle.copyWith(color: Colors.grey[600]),
            ),

            const SizedBox(height: 24),

            // Add contact form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Emergency Contact',
                      style: AppThemes.subheadingStyle,
                    ),

                    const SizedBox(height: 16),

                    CustomTxtField(
                      controller: _nameController,
                      labelText: 'Full Name',
                      prefixIcon: Icons.person,
                      textCapitalization: TextCapitalization.words,
                    ),

                    const SizedBox(height: 12),

                    CustomTxtField(
                      controller: _phoneController,
                      labelText: 'Phone Number',
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 12),

                    CustomTxtField(
                      controller: _relationshipController,
                      labelText: 'Relationship (Optional)',
                      prefixIcon: Icons.family_restroom,
                      hintText: 'e.g., Spouse, Parent, Friend',
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Add Contact',
                        onPressed: _addContact,
                        isLoading: _isAddingContact,
                        variant: ButtonVariant.outlined,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // List of added contacts
            if (contacts.isNotEmpty) ...[
              Text('Added Contacts', style: AppThemes.subheadingStyle),

              const SizedBox(height: 8),

              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            contact.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(contact.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(contact.phoneNumber),
                            if (contact.relationship.isNotEmpty)
                              Text(
                                contact.relationship,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        trailing:
                            contact.isPrimary
                                ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Primary',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                                : null,
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.contact_phone, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No contacts added yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add at least one emergency contact to continue',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Info box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You can skip this step and add contacts later from the settings.',
                      style: AppThemes.bodyStyle.copyWith(
                        fontSize: 14,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
