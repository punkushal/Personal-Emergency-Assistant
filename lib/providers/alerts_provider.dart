import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_emergency_assistant/services/alert_api_service.dart';
import 'package:personal_emergency_assistant/services/location_service.dart';

import '../models/alert.dart';

enum AlertsStatus { initial, loading, loaded, error }

class AlertsState {
  final Alert? alert;
  final AlertsStatus status;
  final String? errorMessage;

  AlertsState({
    required this.alert,
    this.status = AlertsStatus.initial,
    this.errorMessage,
  });

  AlertsState copyWith({
    Alert? alert,
    AlertsStatus? status,
    String? errorMessage,
  }) {
    return AlertsState(
      alert: alert ?? this.alert,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Providers for our services
final alertsApiServiceProvider = Provider<AlertApiService>((ref) {
  return AlertApiService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// StateNotifier for alerts
class AlertsNotifier extends StateNotifier<AlertsState> {
  final AlertApiService _alertsApiService;
  final LocationService _locationService;

  AlertsNotifier(this._alertsApiService, this._locationService)
    : super(AlertsState(alert: null));

  // Fetch alerts for the current location
  Future<void> fetchAlerts() async {
    try {
      // Update state to loading
      state = state.copyWith(status: AlertsStatus.loading);

      // Try to get the current location
      final locationResult = await _locationService.getCurrentLocation();

      // Fetch alerts (with or without location)
      Alert? alert;
      if (locationResult.hasLocation) {
        final position = locationResult.position!;
        alert = await _alertsApiService.fetchWeatherAlerts(
          position.latitude.toString(),
          position.longitude.toString(),
        );
      }

      // Update state with the fetched alerts
      state = state.copyWith(
        alert: alert,
        status: AlertsStatus.loaded,
        errorMessage: null,
      );
    } catch (e) {
      // Update state with error
      state = state.copyWith(
        status: AlertsStatus.error,
        errorMessage: 'Failed to load alerts: $e',
      );
    }
  }

  // Refresh alerts data
  Future<void> refreshAlerts() async {
    await fetchAlerts();
  }
}

// Provider for the AlertsNotifier
final alertsProvider = StateNotifierProvider<AlertsNotifier, AlertsState>((
  ref,
) {
  final alertsApiService = ref.watch(alertsApiServiceProvider);
  final locationService = ref.watch(locationServiceProvider);
  return AlertsNotifier(alertsApiService, locationService);
});
