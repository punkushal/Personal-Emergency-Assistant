import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_emergency_assistant/providers/contacts_provider.dart';

import '../../constants/app_strings.dart';
import '../../constants/app_themes.dart';
import '../../providers/sos_provider.dart';
import '../../widgets/loading_indicator.dart';

class SosButton extends ConsumerStatefulWidget {
  const SosButton({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SosButtonState();
}

class _SosButtonState extends ConsumerState<SosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    //Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start pulsing animation
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  void _showSosConfirmationDialog() {
    final contacts = ref.read(emergencyContactsProvider);

    if (contacts.isEmpty) {
      _showNoContactsDialog();
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (cxt) {
        return AlertDialog(
          title: Row(
            spacing: 8,
            children: [
              Icon(Icons.warning, color: Theme.of(context).primaryColor),
              Text('Emergency Alert'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text('This will send an emergency message with your location t:'),
              ...contacts
                  .take(3)
                  .map(
                    (contact) => Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Row(
                        spacing: 8,
                        children: [
                          Icon(Icons.person, size: 16),
                          Text('${contact.name} (${contact.phoneNumber})'),
                        ],
                      ),
                    ),
                  ),
              if (contacts.length > 3)
                Text('... and ${contacts.length - 3} more contacts'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _sendSosAlert();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: Text('Send Alert'),
            ),
          ],
        );
      },
    );
  }

  void _showNoContactsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Emergency Contacts'),
          content: const Text(
            'You need to add at least one emergency contact before using the SOS feature.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendSosAlert() async {
    final sosNotifier = ref.read(sosProvider.notifier);
    await sosNotifier.sendSosMessage();
  }

  @override
  Widget build(BuildContext context) {
    final sosState = ref.watch(sosProvider);
    final contacts = ref.watch(emergencyContactsProvider);

    //Listen to SOS state changes
    ref.listen<SosState>(sosProvider, (previous, next) {
      if (next.status == SosStatus.sent) {
        _showSuccessDialog();
      } else if (next.status == SosStatus.error) {
        _showErrorDialog(next.errMsg ?? 'Unknown error occured');
      }
    });
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // SOS Button
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale:
                    sosState.status == SosStatus.sending
                        ? _scaleAnimation.value
                        : _pulseAnimation.value,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withValues(alpha: 0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap:
                          sosState.status == SosStatus.sending
                              ? null
                              : _showSosConfirmationDialog,
                      child: Center(
                        child:
                            sosState.status == SosStatus.sending
                                ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    LoadingIndicator(color: Colors.white),
                                    SizedBox(height: 8),
                                    Text(
                                      'Sending...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                                : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.sos,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Emergency Alert',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Instructions
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                Text(
                  'Tap to send emergency alert',
                  style: AppThemes.bodyStyle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${contacts.length} contact${contacts.length != 1 ? 's' : ''} will be notified',
                  style: AppThemes.bodyStyle.copyWith(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    final sosState = ref.read(sosProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600]),
              const SizedBox(width: 8),
              const Text('Alert Sent'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(AppStrings.sosConfirmation),
              if (sosState.sentTo != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Sent to ${sosState.sentTo!.length} contact${sosState.sentTo!.length != 1 ? 's' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(sosProvider.notifier).resetSosState();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red[600]),
              const SizedBox(width: 8),
              const Text('Alert Failed'),
            ],
          ),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(sosProvider.notifier).resetSosState();
              },
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _sendSosAlert();
              },
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
  }
}
