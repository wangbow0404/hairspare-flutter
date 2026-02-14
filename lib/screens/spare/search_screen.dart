import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/compact_announcement_card.dart';
import '../../providers/favorite_provider.dart';
import '../../services/search_service.dart';
import '../../models/job.dart';
import '../../models/space_rental.dart';
import '../../screens/spare/education_screen.dart';
import '../../screens/spare/challenge_screen.dart';
import 'job_detail_screen.dart';
import 'space_rental_detail_screen.dart';
import 'education_detail_screen.dart';

/// 통합 검색 화면 (공고/교육/공간/챌린지)
class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  int _tabIndex = 0; // 0: 전체, 1: 공고, 2: 교육, 3: 공간, 4: 챌린지

  List<Job> _jobs = [];
  List<Education> _educations = [];
  List<SpaceRental> _spaces = [];
  List<Challenge> _challenges = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery ?? '';
    if (_searchController.text.isNotEmpty) {
      _doSearch();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _doSearch() async {
    final query = _searchController.text.trim();
    setState(() => _isLoading = true);

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
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: widget.initialQuery == null || widget.initialQuery!.isEmpty,
          decoration: InputDecoration(
            hintText: '공고, 교육, 공간, 챌린지 검색',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onSubmitted: (_) => _doSearch(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppTheme.primaryBlue),
            onPressed: _doSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppTheme.backgroundWhite,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: AppTheme.spacingSymmetric(horizontal: AppTheme.spacing4, vertical: AppTheme.spacing2),
              child: Row(
                children: [
                  _TabChip(label: '전체', isActive: _tabIndex == 0, onTap: () => setState(() => _tabIndex = 0)),
                  SizedBox(width: AppTheme.spacing2),
                  _TabChip(label: '공고', isActive: _tabIndex == 1, onTap: () => setState(() => _tabIndex = 1)),
                  SizedBox(width: AppTheme.spacing2),
                  _TabChip(label: '교육', isActive: _tabIndex == 2, onTap: () => setState(() => _tabIndex = 2)),
                  SizedBox(width: AppTheme.spacing2),
                  _TabChip(label: '공간', isActive: _tabIndex == 3, onTap: () => setState(() => _tabIndex = 3)),
                  SizedBox(width: AppTheme.spacing2),
                  _TabChip(label: '챌린지', isActive: _tabIndex == 4, onTap: () => setState(() => _tabIndex = 4)),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchController.text.trim().isEmpty
                    ? Center(
                        child: Text(
                          '검색어를 입력해주세요',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      )
                    : _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final hasAny = _jobs.isNotEmpty || _educations.isNotEmpty || _spaces.isNotEmpty || _challenges.isNotEmpty;
    if (!hasAny) {
      return Center(
        child: Text(
          '검색 결과가 없습니다',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      );
    }

    return Consumer<FavoriteProvider>(
      builder: (context, favProvider, _) {
        final favoriteMap = favProvider.favoriteJobIds.fold<Map<String, bool>>(
          {},
          (map, id) => map..[id] = true,
        );

        return SingleChildScrollView(
          padding: AppTheme.spacing(AppTheme.spacing4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_showJobs && _jobs.isNotEmpty) ...[
                _SectionTitle(title: '공고', count: _jobs.length),
                SizedBox(height: AppTheme.spacing2),
                ..._jobs.map((job) => CompactAnnouncementCard(
                      type: AnnouncementType.job,
                      job: job,
                      isFavorite: favoriteMap[job.id] ?? false,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobDetailScreen(jobId: job.id),
                        ),
                      ),
                      onFavoriteToggle: () => favProvider.toggleFavorite(job.id),
                    )),
                SizedBox(height: AppTheme.spacing6),
              ],
              if (_showEducations && _educations.isNotEmpty) ...[
                _SectionTitle(title: '교육', count: _educations.length),
                SizedBox(height: AppTheme.spacing2),
                ..._educations.map((edu) => CompactAnnouncementCard(
                      type: AnnouncementType.education,
                      education: edu,
                      isFavorite: false,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EducationDetailScreen(education: edu),
                        ),
                      ),
                    )),
                SizedBox(height: AppTheme.spacing6),
              ],
              if (_showSpaces && _spaces.isNotEmpty) ...[
                _SectionTitle(title: '공간대여', count: _spaces.length),
                SizedBox(height: AppTheme.spacing2),
                ..._spaces.map((space) => CompactAnnouncementCard(
                      type: AnnouncementType.spaceRental,
                      spaceRental: space,
                      isFavorite: false,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpaceRentalDetailScreen(spaceId: space.id),
                        ),
                      ),
                    )),
                SizedBox(height: AppTheme.spacing6),
              ],
              if (_showChallenges && _challenges.isNotEmpty) ...[
                _SectionTitle(title: '챌린지', count: _challenges.length),
                SizedBox(height: AppTheme.spacing2),
                ..._challenges.map((c) => _ChallengeSearchCard(
                      challenge: c,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChallengeScreen(),
                        ),
                      ),
                    )),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabChip({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppTheme.spacingSymmetric(horizontal: AppTheme.spacing3, vertical: AppTheme.spacing2),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryBlue : AppTheme.backgroundGray,
          borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppTheme.textSecondary,
              ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final int count;

  const _SectionTitle({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$title ($count)',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
    );
  }
}

class _ChallengeSearchCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onTap;

  const _ChallengeSearchCard({required this.challenge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppTheme.spacing3),
        padding: AppTheme.spacing(AppTheme.spacing4),
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.borderGray),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.2),
                borderRadius: AppTheme.borderRadius(AppTheme.radiusMd),
              ),
              child: Icon(Icons.video_library, color: AppTheme.primaryPurple, size: 32),
            ),
            SizedBox(width: AppTheme.spacing3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  SizedBox(height: AppTheme.spacing1),
                  Text(
                    challenge.creatorName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  if (challenge.tags != null && challenge.tags!.isNotEmpty)
                    Text(
                      challenge.tags!.take(3).join(' · '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiary,
                            fontSize: 12,
                          ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }
}
