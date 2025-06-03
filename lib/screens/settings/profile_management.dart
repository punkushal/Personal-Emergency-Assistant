import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_emergency_assistant/constants/app_strings.dart';
import 'package:personal_emergency_assistant/constants/app_themes.dart';
import 'package:personal_emergency_assistant/providers/user_provider.dart';
import 'package:personal_emergency_assistant/widgets/custom_button.dart';
import 'package:personal_emergency_assistant/widgets/custom_txt_field.dart';

class ProfileManagement extends ConsumerStatefulWidget {
  const ProfileManagement({super.key});

  @override
  ConsumerState<ProfileManagement> createState() => _ProfileManagementState();
}

class _ProfileManagementState extends ConsumerState<ProfileManagement> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _medicalConditionsController =
      TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();

  String _selectedBloodGroup = 'O+';
  bool _isLoading = false;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfile = ref.read(userProfileProvider);
      if (userProfile != null) {
        _nameController.text = userProfile.name;
        _selectedBloodGroup = userProfile.bloodGroup;
        _allergiesController.text = userProfile.allergies;
        _medicalConditionsController.text = userProfile.medicalConditions;
        _medicationsController.text = userProfile.medications;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _allergiesController.dispose();
    _medicalConditionsController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This information will be included in emergency alerts to help first responders provide better care.',
                style: AppThemes.bodyStyle.copyWith(color: Colors.grey[600]),
              ),

              const SizedBox(height: 24),

              // Basic Information
              Text('Basic Information', style: AppThemes.subheadingStyle),

              const SizedBox(height: 12),

              CustomTxtField(
                controller: _nameController,
                labelText: AppStrings.fullNameLabel,
                prefixIcon: Icons.person,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: const InputDecoration(
                  labelText: AppStrings.bloodGroupLabel,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.bloodtype),
                ),
                items:
                    _bloodGroups.map((bloodGroup) {
                      return DropdownMenuItem(
                        value: bloodGroup,
                        child: Text(bloodGroup),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBloodGroup = value!;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Medical Information
              Text('Medical Information', style: AppThemes.subheadingStyle),

              const SizedBox(height: 12),

              CustomTxtField(
                controller: _allergiesController,
                labelText: AppStrings.allergiesLabel,
                prefixIcon: Icons.warning,
                hintText: 'e.g., Penicillin, Nuts, Pollen',
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              CustomTxtField(
                controller: _medicalConditionsController,
                labelText: 'Medical Conditions',
                prefixIcon: Icons.medical_services,
                hintText: 'e.g., Diabetes, Hypertension, Asthma',
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              CustomTxtField(
                controller: _medicationsController,
                labelText: 'Current Medications',
                prefixIcon: Icons.medication,
                hintText: 'e.g., Insulin, Aspirin, Inhaler',
                maxLines: 2,
              ),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: AppStrings.saveChanges,
                  onPressed: _saveProfile,
                  isLoading: _isLoading,
                  variant: ButtonVariant.filled,
                ),
              ),

              const SizedBox(height: 16),

              // Privacy notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.privacy_tip, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privacy Notice',
                            style: AppThemes.subheadingStyle.copyWith(
                              color: Colors.blue[700],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your medical information is stored locally on your device and is only shared during emergency situations to help first responders provide appropriate care.',
                            style: AppThemes.bodyStyle.copyWith(
                              color: Colors.blue[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userNotifier = ref.read(userProfileProvider.notifier);
      final success = await userNotifier.saveUserProfile(
        name: _nameController.text.trim(),
        bloodGroup: _selectedBloodGroup,
        allergies: _allergiesController.text.trim(),
        medicalConditions: _medicalConditionsController.text.trim(),
        medications: _medicationsController.text.trim(),
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update profile'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
