import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_emergency_assistant/constants/app_strings.dart';
import 'package:personal_emergency_assistant/constants/app_themes.dart';
import 'package:personal_emergency_assistant/providers/contacts_provider.dart';
import 'package:personal_emergency_assistant/providers/user_provider.dart';
import 'package:personal_emergency_assistant/screens/first_aid/first_aid_guide_screen.dart';
import 'package:personal_emergency_assistant/screens/home/emergency_info_card.dart';
import 'package:personal_emergency_assistant/screens/home/sos_button.dart';
import 'package:personal_emergency_assistant/screens/settings/settings_screen.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  String capitalize(String word) {
    String capitalized = word[0].toUpperCase() + word.substring(1);
    return capitalized;
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final contacts = ref.watch(emergencyContactsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${capitalize(userProfile!.name)}'),
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Quick status check
              if (contacts.isEmpty)
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange[700]),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Setup Required',
                              style: AppThemes.subheadingStyle.copyWith(
                                color: Colors.orange[700],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add emergency contacts',
                              style: AppThemes.bodyStyle.copyWith(
                                color: Colors.orange[700],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => SettingsScreen(),
                            ),
                          );
                        },
                        child: Text('Setup'),
                      ),
                    ],
                  ),
                ),

              //SOS Button - Main feature
              SosButton(),
              SizedBox(height: 24),

              //Emergency info card
              ...[
                Text(
                  AppStrings.emergencyInfoTitle,
                  style: AppThemes.subheadingStyle,
                ),
                SizedBox(height: 12),
                EmergencyInfoCard(userProfile: userProfile),
                SizedBox(height: 24),
              ],

              //Quick Actions Grid
              Text('Quick Actions', style: AppThemes.subheadingStyle),
              SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildQuickActionCard(
                    context,
                    'First Aid',
                    'Get medical help',
                    Icons.medical_services,
                    Colors.red,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FirstAidGuideScreen(),
                        ),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    'Contacts',
                    'Emergency contacts',
                    Icons.contacts,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                  _buildQuickActionCard(
                    context,
                    'Settings',
                    'App preferences',
                    Icons.settings,
                    Colors.grey,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              //Emergency Tips Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Emergency Tip',
                          style: AppThemes.subheadingStyle.copyWith(
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'In an emergency, stay calm and assess the situation before taking action. Remember: your safety comes first.',
                      style: AppThemes.bodyStyle.copyWith(
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
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppThemes.subheadingStyle.copyWith(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppThemes.bodyStyle.copyWith(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
