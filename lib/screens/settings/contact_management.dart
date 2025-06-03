import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_emergency_assistant/constants/app_themes.dart';
import 'package:personal_emergency_assistant/models/emergency_contact.dart';
import 'package:personal_emergency_assistant/providers/contacts_provider.dart';
import 'package:personal_emergency_assistant/widgets/custom_button.dart';
import 'package:personal_emergency_assistant/widgets/custom_txt_field.dart';

class ContactManagement extends ConsumerStatefulWidget {
  const ContactManagement({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ContactManagementState();
}

class _ContactManagementState extends ConsumerState<ContactManagement> {
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

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(emergencyContactsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Column(
        children: [
          //Contact form
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add New Contact', style: AppThemes.subheadingStyle),
                  CustomTxtField(
                    controller: _nameController,
                    labelText: 'Full Name',
                    prefixIcon: Icons.person,
                    textCapitalization: TextCapitalization.words,
                  ),
                  CustomTxtField(
                    controller: _phoneController,
                    labelText: 'Phone Number',
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  CustomTxtField(
                    controller: _relationshipController,
                    labelText: 'Relationship (Optional)',
                    prefixIcon: Icons.family_restroom,
                    hintText: 'e.g., Spouse, Parent, Friend',
                  ),
                  SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Add Contact',
                      variant: ButtonVariant.filled,
                      isLoading: _isAddingContact,
                      onPressed: _addContact,
                    ),
                  ),
                ],
              ),
            ),
          ),

          //Contacts List
          Expanded(
            child:
                contacts.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.contact_phone,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No emergency contacts added',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add contacts who should receive your SOS alerts',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: contacts.length,
                      itemBuilder: (ctx, index) {
                        final contact = contacts[index];
                        return _buildContactCard(contact);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              contact.isPrimary
                  ? Theme.of(context).primaryColor
                  : Colors.grey[400],
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
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'primary':
                _setPrimaryContact(contact);
                break;
              case 'edit':
                _editContact(contact);
                break;
              case 'delete':
                _deleteContact(contact);
                break;
            }
          },
          itemBuilder:
              (context) => [
                if (!contact.isPrimary)
                  const PopupMenuItem(
                    value: 'primary',
                    child: Text('Set as Primary'),
                  ),
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
        ),
        onTap: () => _showContactDetails(contact),
      ),
    );
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
      );

      if (success) {
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

  Future<void> _setPrimaryContact(EmergencyContact contact) async {
    final contactsNotifier = ref.read(emergencyContactsProvider.notifier);
    final success = await contactsNotifier.updateContact(
      id: contact.id,
      isPrimary: true,
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${contact.name} set as primary contact'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _editContact(EmergencyContact contact) {
    // Set the form fields with current contact data
    _nameController.text = contact.name;
    _phoneController.text = contact.phoneNumber;
    _relationshipController.text = contact.relationship;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Contact'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTxtField(
                  controller: _nameController,
                  labelText: 'Full Name',
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                CustomTxtField(
                  controller: _phoneController,
                  labelText: 'Phone Number',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                CustomTxtField(
                  controller: _relationshipController,
                  labelText: 'Relationship',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _clearForm();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _updateContact(contact);
                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  Future<void> _updateContact(EmergencyContact contact) async {
    final contactsNotifier = ref.read(emergencyContactsProvider.notifier);
    final success = await contactsNotifier.updateContact(
      id: contact.id,
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      relationship: _relationshipController.text.trim(),
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _clearForm();
    }
  }

  Future<void> _deleteContact(EmergencyContact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Contact'),
            content: Text('Are you sure you want to delete ${contact.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final contactsNotifier = ref.read(emergencyContactsProvider.notifier);
      final success = await contactsNotifier.removeContact(contact.id);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${contact.name} deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  void _showContactDetails(EmergencyContact contact) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(contact.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16),
                    const SizedBox(width: 8),
                    Text(contact.phoneNumber),
                  ],
                ),
                if (contact.relationship.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.family_restroom, size: 16),
                      const SizedBox(width: 8),
                      Text(contact.relationship),
                    ],
                  ),
                ],
                if (contact.isPrimary) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      const Text('Primary Contact'),
                    ],
                  ),
                ],
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

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _relationshipController.clear();
  }
}
