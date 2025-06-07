import 'package:flutter/material.dart';
import 'package:personal_emergency_assistant/constants/app_themes.dart';
import 'package:personal_emergency_assistant/models/user_profile.dart';

class EmergencyInfoCard extends StatelessWidget {
  final UserProfile userProfile;

  const EmergencyInfoCard({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medical_information,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Medical Information',
                  style: AppThemes.subheadingStyle.copyWith(fontSize: 16),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'For First Responders',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Medical information grid
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    'Name',
                    userProfile.name,
                    Icons.person,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    'Blood Type',
                    userProfile.bloodGroup,
                    Icons.bloodtype,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildInfoItem(
              context,
              'Allergies',
              userProfile.allergies.isEmpty
                  ? 'None reported'
                  : userProfile.allergies,
              Icons.warning,
              isFullWidth: true,
            ),

            if (userProfile.medicalConditions.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoItem(
                context,
                'Medical Conditions',
                userProfile.medicalConditions,
                Icons.medical_services,
                isFullWidth: true,
              ),
            ],

            if (userProfile.medications.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoItem(
                context,
                'Current Medications',
                userProfile.medications,
                Icons.medication,
                isFullWidth: true,
              ),
            ],

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[700], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This information is displayed for emergency responders to provide better care.',
                      style: AppThemes.bodyStyle.copyWith(
                        fontSize: 12,
                        color: Colors.blue[700],
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

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child:
          isFullWidth
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: AppThemes.bodyStyle.copyWith(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppThemes.bodyStyle.copyWith(fontSize: 14),
                  ),
                ],
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: AppThemes.bodyStyle.copyWith(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppThemes.bodyStyle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
    );
  }
}
