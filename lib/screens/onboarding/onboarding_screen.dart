import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_emergency_assistant/constants/app_strings.dart';
import 'package:personal_emergency_assistant/constants/app_themes.dart';
import 'package:personal_emergency_assistant/providers/user_provider.dart';
import 'package:personal_emergency_assistant/screens/home/home_screen.dart';
import 'package:personal_emergency_assistant/screens/onboarding/onboarding_form.dart';
import 'package:personal_emergency_assistant/widgets/custom_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  //Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for form inputs
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  String _selectedBloodGroup = 'O+';

  //Validation flags
  bool _hasAttemptedValidation = false;

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

  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  //Validate profile form
  bool _validateProfileForm() {
    setState(() {
      _hasAttemptedValidation = true;
    });
    if (_formKey.currentState!.validate()) {
      return true;
    }
    _showErrorSnackBar('Please fill in all required fields');
    return false;
  }

  // Complete onboarding and navigate to home
  Future<void> _completeOnboarding() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Save user profile
      final userNotifier = ref.read(userProfileProvider.notifier);
      final success = await userNotifier.saveUserProfile(
        name: _nameController.text.trim(),
        bloodGroup: _selectedBloodGroup,
        allergies: _allergiesController.text.trim(),
      );

      if (success) {
        // Mark onboarding as completed
        final storageService = ref.read(storageServiceProvider);
        await storageService.setHasCompletedOnboarding(true);

        // Navigate to home screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        _showErrorSnackBar('Failed to save profile. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _nextPage() {
    //Validate profile form if on profile page
    if (_currentPage == 1 && !_validateProfileForm()) {
      return;
    }
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / 3,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildWelcomePage(),
                  _buildProfilePage(),
                  _buildContactsPage(),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: CustomButton(
                        text: 'Back',
                        onPressed: _previousPage,
                        variant: ButtonVariant.outlined,
                        isLoading: _isLoading,
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: _currentPage == 2 ? 'Get Started' : 'Continue',
                      onPressed:
                          _currentPage == 2 ? _completeOnboarding : _nextPage,
                      isLoading: _isLoading,
                      variant: ButtonVariant.outlined,
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

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App icon or illustration
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.health_and_safety,
              size: 60,
              color: Theme.of(context).primaryColor,
            ),
          ),

          const SizedBox(height: 32),

          Text(
            AppStrings.onboardingTitle,
            style: AppThemes.headingStyle,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            'Your personal safety companion that helps you in emergency situations with quick SOS alerts, first-aid guides, and emergency information.',
            style: AppThemes.bodyStyle.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // Features list
          _buildFeatureItem(
            Icons.sos,
            'Quick SOS Alerts',
            'Send emergency messages with your location to contacts',
          ),

          const SizedBox(height: 16),

          _buildFeatureItem(
            Icons.medical_services,
            'First Aid Guides',
            'Access essential first-aid instructions offline',
          ),

          const SizedBox(height: 16),

          _buildFeatureItem(
            Icons.warning,
            'Emergency Alerts',
            'Get real-time alerts for your area',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppThemes.subheadingStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppThemes.bodyStyle.copyWith(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              Text('Personal Information', style: AppThemes.headingStyle),

              const SizedBox(height: 8),

              Text(
                'This information will be included in emergency alerts to help first responders.',
                style: AppThemes.bodyStyle.copyWith(color: Colors.grey[600]),
              ),

              const SizedBox(height: 32),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: AppStrings.fullNameLabel,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Full name is required';
                  }
                  if (value.trim().length < 6) {
                    return 'Name must be at least 6 characters long';
                  }
                  return null;
                },
                autovalidateMode:
                    _hasAttemptedValidation
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
              ),

              const SizedBox(height: 16),

              // Blood group dropdown
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select your blood group';
                  }
                  return null;
                },
                autovalidateMode:
                    _hasAttemptedValidation
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
              ),

              const SizedBox(height: 16),

              // Allergies field
              TextFormField(
                controller: _allergiesController,
                decoration: const InputDecoration(
                  labelText: AppStrings.allergiesLabel,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.warning),
                  hintText: 'e.g., Penicillin, Nuts, etc.',
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This information is stored locally on your device and will only be shared during emergency situations.',
                        style: AppThemes.bodyStyle.copyWith(
                          fontSize: 14,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactsPage() {
    return const OnboardingContactsForm();
  }
}
