import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_emergency_assistant/models/first_aid_guide.dart';
import 'package:personal_emergency_assistant/services/first_aid_service.dart';

enum FirstAidStatus { initial, loading, loaded, error }

class FirstAidState {
  final List<FirstAidGuide> guides;
  final List<FirstAidGuide> filteredGuides;
  final List<String> categories;
  final String? selectedCategory;
  final String searchQuery;
  final FirstAidStatus status;
  final String? errorMessage;

  FirstAidState({
    this.guides = const [],
    this.filteredGuides = const [],
    this.categories = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.status = FirstAidStatus.initial,
    this.errorMessage,
  });

  FirstAidState copyWith({
    List<FirstAidGuide>? guides,
    List<FirstAidGuide>? filteredGuides,
    List<String>? categories,
    String? selectedCategory,
    String? searchQuery,
    FirstAidStatus? status,
    String? errorMessage,
  }) {
    return FirstAidState(
      guides: guides ?? this.guides,
      filteredGuides: filteredGuides ?? this.filteredGuides,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Provider for the FirstAidService
final firstAidServiceProvider = Provider<FirstAidService>((ref) {
  return FirstAidService();
});

// StateNotifier for first aid guides
class FirstAidNotifier extends StateNotifier<FirstAidState> {
  final FirstAidService _firstAidService;

  FirstAidNotifier(this._firstAidService) : super(FirstAidState()) {
    // Load guides when initialized
    loadGuides();
  }

  // Load guides from assets
  Future<void> loadGuides() async {
    try {
      // Update state to loading
      state = state.copyWith(status: FirstAidStatus.loading);

      // Load guides
      final guides = await _firstAidService.loadFirstAidGuides();

      // Extract categories
      final categories = _firstAidService.getAllCategories(guides);

      // Update state
      state = state.copyWith(
        guides: guides,
        filteredGuides: guides,
        categories: categories,
        status: FirstAidStatus.loaded,
        errorMessage: null,
      );
    } catch (e) {
      // Update state with error
      state = state.copyWith(
        status: FirstAidStatus.error,
        errorMessage: 'Failed to load first aid guides: $e',
      );
    }
  }

  // Filter guides by search query
  void searchGuides(String query) {
    List<FirstAidGuide> filtered = _firstAidService.searchGuides(
      state.guides,
      query,
    );

    // Apply category filter if selected
    if (state.selectedCategory != null) {
      filtered = _firstAidService.getGuidesByCategory(
        filtered,
        state.selectedCategory!,
      );
    }

    state = state.copyWith(searchQuery: query, filteredGuides: filtered);
  }

  // Filter guides by category
  void selectCategory(String? category) {
    List<FirstAidGuide> filtered;

    if (category == null) {
      // Reset to all guides
      filtered = state.guides;
    } else {
      // Filter by category
      filtered = _firstAidService.getGuidesByCategory(state.guides, category);
    }

    // Apply search filter if there's a query
    if (state.searchQuery.isNotEmpty) {
      filtered = _firstAidService.searchGuides(filtered, state.searchQuery);
    }

    state = state.copyWith(
      selectedCategory: category,
      filteredGuides: filtered,
    );
  }
}

// Provider for the FirstAidNotifier
final firstAidProvider = StateNotifierProvider<FirstAidNotifier, FirstAidState>(
  (ref) {
    final firstAidService = ref.watch(firstAidServiceProvider);
    return FirstAidNotifier(firstAidService);
  },
);
