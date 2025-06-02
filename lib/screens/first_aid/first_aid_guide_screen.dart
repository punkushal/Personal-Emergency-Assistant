import 'package:flutter/material.dart';
import 'package:personal_emergency_assistant/constants/app_themes.dart';
import 'package:personal_emergency_assistant/models/first_aid_guide.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_emergency_assistant/constants/app_strings.dart';
import 'package:personal_emergency_assistant/providers/first_aid_provider.dart';
import 'package:personal_emergency_assistant/screens/first_aid/guide_detail_screen.dart';
import 'package:personal_emergency_assistant/widgets/error_view.dart';
import 'package:personal_emergency_assistant/widgets/loading_indicator.dart';

import '../../widgets/custom_txt_field.dart';

class FirstAidGuideScreen extends ConsumerStatefulWidget {
  const FirstAidGuideScreen({super.key});

  @override
  ConsumerState<FirstAidGuideScreen> createState() =>
      _FirstAidGuideScreenState();
}

class _FirstAidGuideScreenState extends ConsumerState<FirstAidGuideScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firstAidState = ref.watch(firstAidProvider);
    final firstAidNotifier = ref.read(firstAidProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.firstAidGuidesTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar
                CustomTxtField(
                  controller: _searchController,
                  hintText: AppStrings.searchGuides,
                  prefixIcon: Icons.search,
                  onChanged: (query) {
                    firstAidNotifier.searchGuides(query);
                  },
                ),

                const SizedBox(height: 12),

                // Category filter
                if (firstAidState.categories.isNotEmpty)
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: firstAidState.categories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: const Text('All'),
                              selected: _selectedCategory == null,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = null;
                                });
                                firstAidNotifier.selectCategory(null);
                              },
                            ),
                          );
                        }

                        final category = firstAidState.categories[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = selected ? category : null;
                              });
                              firstAidNotifier.selectCategory(
                                selected ? category : null,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Expanded(child: _buildContent(firstAidState, firstAidNotifier)),
        ],
      ),
    );
  }

  Widget _buildContent(FirstAidState state, FirstAidNotifier notifier) {
    switch (state.status) {
      case FirstAidStatus.loading:
        return const Center(child: LoadingIndicator());

      case FirstAidStatus.error:
        return ErrorView(
          title: 'Error Loading Guides',
          message: state.errorMessage ?? 'Unknown error occurred',
          onRetry: () => notifier.loadGuides(),
        );

      case FirstAidStatus.loaded:
        if (state.filteredGuides.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  AppStrings.noGuidesFound,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: state.filteredGuides.length,
          itemBuilder: (context, index) {
            final guide = state.filteredGuides[index];
            return _buildGuideCard(guide);
          },
        );

      default:
        return const Center(child: LoadingIndicator());
    }
  }

  Widget _buildGuideCard(FirstAidGuide guide) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GuideDetailScreen(guide: guide)),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Emergency indicator
                  if (guide.isEmergency)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emergency,
                            size: 14,
                            color: Colors.red[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Emergency',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      guide.category,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Title
              Text(
                guide.title,
                style: AppThemes.subheadingStyle.copyWith(fontSize: 16),
              ),

              const SizedBox(height: 8),

              // Steps preview
              Text(
                '${guide.steps.length} step${guide.steps.length != 1 ? 's' : ''}',
                style: AppThemes.bodyStyle.copyWith(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),

              if (guide.steps.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Step 1: ${guide.steps.first.desc}',
                  style: AppThemes.bodyStyle.copyWith(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Tags
              if (guide.tags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children:
                      guide.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        );
                      }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
