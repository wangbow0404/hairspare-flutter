import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../models/challenge_feed.dart';
import '../../models/job.dart';
import '../../models/space_rental.dart';
import '../../providers/favorite_provider.dart';
import '../../screens/spare/education_screen.dart';
import '../../services/search_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/job_popularity.dart';
import '../../utils/spare_search_hints.dart';
import '../../widgets/compact_announcement_card.dart';
import '../../widgets/stitch/stitch_empty_state.dart';
import '../../widgets/stitch/stitch_filter_chip.dart';
import '../../widgets/stitch/stitch_list_job_card.dart';
import '../../widgets/stitch/stitch_list_tile.dart';

/// 통합 검색 (공고·교육·공간·챌린지) — Stitch 스페어 서브페이지 스타일.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final SearchService _searchService = SearchService();
  int _tabIndex = 0;

  List<Job> _jobs = [];
  List<Education> _educations = [];
  List<SpaceRental> _spaces = [];
  List<Challenge> _challenges = [];

  bool _isLoading = false;
  bool _showResults = false;

  static const _tabLabels = ['전체', '공고', '교육', '공간', '챌린지'];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery ?? '';
    if (_searchController.text.trim().isNotEmpty) {
      _doSearch();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _applySuggestion(String keyword) {
    _searchController.text = keyword;
    _searchController.selection = TextSelection.collapsed(
      offset: keyword.length,
    );
    setState(() {
      _tabIndex = SpareSearchHints.suggestedTabIndex(keyword);
    });
    _searchFocus.unfocus();
    _doSearch();
  }

  Future<void> _doSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _showResults = false;
        _jobs = [];
        _educations = [];
        _spaces = [];
        _challenges = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showResults = true;
    });

    try {
      final results = await Future.wait([
        _searchService.searchJobs(query),
        _searchService.searchEducations(query),
        _searchService.searchSpaces(query),
        _searchService.searchChallenges(query),
      ]);
      if (mounted) {
        setState(() {
          _jobs = results[0] as List<Job>;
          _educations = results[1] as List<Education>;
          _spaces = results[2] as List<SpaceRental>;
          _challenges = results[3] as List<Challenge>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool get _showJobs => _tabIndex == 0 || _tabIndex == 1;
  bool get _showEducations => _tabIndex == 0 || _tabIndex == 2;
  bool get _showSpaces => _tabIndex == 0 || _tabIndex == 3;
  bool get _showChallenges => _tabIndex == 0 || _tabIndex == 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SearchScreenHeader(
              controller: _searchController,
              focusNode: _searchFocus,
              requestInitialFocus:
                  widget.initialQuery == null || widget.initialQuery!.isEmpty,
              onSubmitted: (_) => _doSearch(),
              onSearchPressed: _doSearch,
              onBack: () => Navigator.maybePop(context),
            ),
            const SearchScreenGradientBar(),
            SearchCategoryChips(
              labels: _tabLabels,
              activeIndex: _tabIndex,
              onChanged: (index) => setState(() => _tabIndex = index),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.stitchPrimaryContainer,
                      ),
                    )
                  : !_showResults
                  ? SearchEmptySuggestionsBody(
                      onSuggestionTap: _applySuggestion,
                    )
                  : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final hasAny = _jobs.isNotEmpty ||
        _educations.isNotEmpty ||
        _spaces.isNotEmpty ||
        _challenges.isNotEmpty;
    if (!hasAny) {
      return const StitchEmptyState(
        message: '검색 결과가 없습니다\n다른 검색어로 다시 시도해 보세요',
        iconName: 'search',
      );
    }

    return Consumer<FavoriteProvider>(
      builder: (context, favProvider, _) {
        final favoriteMap = favProvider.favoriteJobIds.fold<Map<String, bool>>(
          {},
          (map, id) => map..[id] = true,
        );
        final popularJobIds = JobPopularity.popularJobIds(_jobs);

        return ListView(
          padding: AppTheme.spacingSymmetric(
            horizontal: AppTheme.spacing4,
            vertical: AppTheme.spacing4,
          ),
          children: [
            if (_showJobs && _jobs.isNotEmpty) ...[
              SearchResultSectionHeader(title: '공고', count: _jobs.length),
              const SizedBox(height: AppTheme.spacing3),
              ..._jobs.map(
                (job) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacing3),
                  child: StitchListJobCard(
                    job: job,
                    isFavorite: favoriteMap[job.id] ?? false,
                    showPopularBadge: JobPopularity.showsPopularBadge(
                      job,
                      popularJobIds,
                    ),
                    onTap: () =>
                        context.push(AppRoutes.spareHomeJobDetail(job.id)),
                    onFavoriteToggle: () =>
                        favProvider.toggleFavorite(job.id),
                    margin: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing4),
            ],
            if (_showEducations && _educations.isNotEmpty) ...[
              SearchResultSectionHeader(title: '교육', count: _educations.length),
              const SizedBox(height: AppTheme.spacing3),
              ..._educations.map(
                (edu) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacing3),
                  child: CompactAnnouncementCard(
                    type: AnnouncementType.education,
                    education: edu,
                    isFavorite: false,
                    onTap: () => context.push(
                      AppRoutes.spareHomeEducationDetail,
                      extra: edu,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing4),
            ],
            if (_showSpaces && _spaces.isNotEmpty) ...[
              SearchResultSectionHeader(
                title: '공간대여',
                count: _spaces.length,
              ),
              const SizedBox(height: AppTheme.spacing3),
              ..._spaces.map(
                (space) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacing3),
                  child: CompactAnnouncementCard(
                    type: AnnouncementType.spaceRental,
                    spaceRental: space,
                    isFavorite: false,
                    onTap: () => context.push(
                      AppRoutes.spareHomeSpaceDetail(space.id),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing4),
            ],
            if (_showChallenges && _challenges.isNotEmpty) ...[
              SearchResultSectionHeader(
                title: '챌린지',
                count: _challenges.length,
              ),
              const SizedBox(height: AppTheme.spacing3),
              ..._challenges.map(
                (challenge) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacing2),
                  child: SearchChallengeTile(
                    challenge: challenge,
                    onTap: () => context.push(AppRoutes.spareHomeChallenge),
                  ),
                ),
              ),
            ],
            SizedBox(height: MediaQuery.paddingOf(context).bottom + 16),
          ],
        );
      },
    );
  }
}

class SearchScreenHeader extends StatelessWidget {
  const SearchScreenHeader({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onSearchPressed,
    required this.onBack,
    this.requestInitialFocus = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSearchPressed;
  final VoidCallback onBack;
  final bool requestInitialFocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderGray, width: 1),
        ),
      ),
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing2,
        vertical: AppTheme.spacing2,
      ),
      child: Row(
        children: [
          IconButton(
            icon: IconMapper.icon(
                  'chevronleft',
                  size: 24,
                  color: AppTheme.textSecondary,
                ) ??
                const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
            onPressed: onBack,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.backgroundGray,
                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                border: Border.all(color: AppTheme.borderGray),
              ),
              child: SearchInputField(
                controller: controller,
                focusNode: focusNode,
                requestInitialFocus: requestInitialFocus,
                onSubmitted: onSubmitted,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacing1),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSearchPressed,
              borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.stitchPrimaryContainer,
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                ),
                alignment: Alignment.center,
                child: IconMapper.icon(
                      'search',
                      size: 22,
                      color: Colors.white,
                    ) ??
                    const Icon(Icons.search, size: 22, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// IME 조합을 깨지 않도록 hint는 포커스 변경·타이머에만 갱신 (입력 중 리빌드 없음).
class SearchInputField extends StatefulWidget {
  const SearchInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    this.requestInitialFocus = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final bool requestInitialFocus;

  @override
  State<SearchInputField> createState() => _SearchInputFieldState();
}

class _SearchInputFieldState extends State<SearchInputField> {
  static const _hintInterval = Duration(seconds: 3);

  final Random _random = Random();
  late String _idleHint;
  String? _currentKeyword;
  Timer? _hintTimer;

  @override
  void initState() {
    super.initState();
    _idleHint = SpareSearchHints.randomHint(_random);
    _currentKeyword = SpareSearchHints.keywordFromHint(_idleHint);
    _hintTimer = Timer.periodic(_hintInterval, (_) => _rotateHint());
    if (widget.requestInitialFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.controller.text.isEmpty) {
          widget.focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  void _rotateHint() {
    if (widget.focusNode.hasFocus || widget.controller.text.isNotEmpty) {
      return;
    }
    setState(() {
      _idleHint = SpareSearchHints.randomHint(
        _random,
        excludeKeyword: _currentKeyword,
      );
      _currentKeyword = SpareSearchHints.keywordFromHint(_idleHint);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const ValueKey('spare_search_field'),
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.none,
      textInputAction: TextInputAction.search,
      autocorrect: false,
      enableSuggestions: true,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppTheme.stitchTextPrimary,
      ),
      decoration: InputDecoration(
        hintText: _idleHint,
        hintStyle: const TextStyle(
          fontSize: 15,
          color: AppTheme.stitchTextSecondary,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: IconMapper.icon(
              'search',
              size: 20,
              color: AppTheme.stitchTextSecondary,
            ) ??
            const Icon(
              Icons.search,
              size: 20,
              color: AppTheme.stitchTextSecondary,
            ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacing2,
        ),
        isDense: true,
      ),
      onSubmitted: widget.onSubmitted,
    );
  }
}

class SearchEmptySuggestionsBody extends StatelessWidget {
  const SearchEmptySuggestionsBody({
    super.key,
    required this.onSuggestionTap,
  });

  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing6,
        vertical: AppTheme.spacing6,
      ),
      child: Column(
        children: [
          const SizedBox(height: AppTheme.spacing8),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.primaryPurpleLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Center(
              child: IconMapper.icon(
                    'search',
                    size: 32,
                    color: AppTheme.stitchPrimary,
                  ) ??
                  const Icon(
                    Icons.search,
                    size: 32,
                    color: AppTheme.stitchPrimary,
                  ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          const Text(
            '검색어를 입력해주세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.stitchTextPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          const Text(
            '공고, 교육, 공간, 챌린지를 찾아볼 수 있어요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.stitchTextSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '추천 검색어',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.stitchTextPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          Wrap(
            spacing: AppTheme.spacing2,
            runSpacing: AppTheme.spacing2,
            children: [
              for (final keyword in SpareSearchHints.quickPickKeywords)
                StitchFilterChip(
                  label: keyword,
                  isSelected: false,
                  onTap: () => onSuggestionTap(keyword),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class SearchScreenGradientBar extends StatelessWidget {
  const SearchScreenGradientBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.stitchPrimaryContainer, AppTheme.stitchPrimary],
        ),
      ),
    );
  }
}

class SearchCategoryChips extends StatelessWidget {
  const SearchCategoryChips({
    super.key,
    required this.labels,
    required this.activeIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundWhite,
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing3,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              if (i > 0) const SizedBox(width: AppTheme.spacing2),
              StitchFilterChip(
                label: labels[i],
                isSelected: activeIndex == i,
                onTap: () => onChanged(i),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SearchResultSectionHeader extends StatelessWidget {
  const SearchResultSectionHeader({
    super.key,
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.stitchTextPrimary,
          ),
        ),
        const SizedBox(width: AppTheme.spacing2),
        Container(
          padding: AppTheme.spacingSymmetric(
            horizontal: AppTheme.spacing2,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryPurpleLight,
            borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.stitchPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class SearchChallengeTile extends StatelessWidget {
  const SearchChallengeTile({
    super.key,
    required this.challenge,
    required this.onTap,
  });

  final Challenge challenge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tags = challenge.tags?.take(3).join(' · ');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: StitchListTile(
        title: challenge.title,
        subtitle: tags != null && tags.isNotEmpty
            ? '$tags · ${challenge.creatorName}'
            : challenge.creatorName,
        leadingIconName: 'video',
        onTap: onTap,
      ),
    );
  }
}
