import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../mocks/mock_auth_data.dart';
import '../../models/match_profile.dart';
import '../../models/model_application_search_item.dart';
import '../../providers/auth_provider.dart';
import '../../services/matching_service.dart';
import '../../services/portfolio_service.dart';
import '../../services/spare_designer_profile_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';

/// "날짜검색" 결과에서 모델 하나를 골랐을 때 보여주는 프로필 화면 — 하트 보내기 포함.
/// 채팅은 모델이 하트를 수락해야 열린다("받은 관심" 화면에서 모델이 수락 → 채팅 시작).
class ModelSearchProfileScreen extends StatefulWidget {
  const ModelSearchProfileScreen({super.key, required this.item});

  final ModelApplicationSearchItem item;

  @override
  State<ModelSearchProfileScreen> createState() =>
      _ModelSearchProfileScreenState();
}

class _ModelSearchProfileScreenState extends State<ModelSearchProfileScreen> {
  bool _isSendingHeart = false;
  bool _heartSent = false;

  Future<void> _sendHeart() async {
    if (_isSendingHeart || _heartSent) return;
    setState(() => _isSendingHeart = true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser ??
          MockAuthData.spareUser();
      final portfolio = await sl<PortfolioService>().getImageUrls(
        ownerId: user.id,
        ownerRole: user.role.name,
      );
      final designerProfile =
          await sl<SpareDesignerProfileService>().getProfile(user.id);
      final intro = designerProfile.matchingIntro.trim().isNotEmpty
          ? designerProfile.matchingIntro.trim()
          : '${user.name ?? user.username} ${designerProfile.roleLabel}';
      final fromProfile = MatchProfile(
        id: user.id,
        role: 'spare',
        displayName: user.name ?? user.username,
        subtitle: designerProfile.matchSubtitle,
        intro: intro,
        tags: designerProfile.matchTags,
        region: designerProfile.regionLabel,
        treatment: designerProfile.specialties.isNotEmpty
            ? designerProfile.specialties.first
            : designerProfile.roleLabel,
        portfolioImages: portfolio,
        avatarUrl: portfolio.isNotEmpty ? portfolio.first : user.profileImage,
      );

      await sl<MatchingService>().sendLikeToModel(
        fromProfile: fromProfile,
        targetModel: widget.item.model,
      );

      if (!mounted) return;
      setState(() => _heartSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('하트를 보냈어요! 모델이 수락하면 채팅할 수 있어요')),
      );
    } catch (e) {
      if (!mounted) return;
      final ex = ErrorHandler.handleException(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getUserFriendlyMessage(ex)),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSendingHeart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.item.model;
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareSubpageAppBar(title: model.name.isEmpty ? '모델 프로필' : model.name),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacing4,
          AppTheme.spacing4,
          AppTheme.spacing4,
          AppTheme.spacing8,
        ),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            child: AspectRatio(
              aspectRatio: 1,
              child: AppNetworkImage(
                imageUrl: model.primaryImage,
                fit: BoxFit.cover,
                fallbackIcon: Icons.person_outline,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                model.name.isEmpty ? '모델' : model.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (model.age > 0) ...[
                const SizedBox(width: AppTheme.spacing2),
                Text(
                  '${model.age}',
                  style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                ),
              ],
            ],
          ),
          if (model.region.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 16, color: AppTheme.textTertiary),
                const SizedBox(width: 4),
                Text(
                  model.region,
                  style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppTheme.spacing4),
          _AvailabilityCard(item: widget.item),
          if (model.intro != null && model.intro!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacing4),
            Text(
              model.intro!,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: AppTheme.spacing4),
          _InfoRow(label: '기장', value: model.hairLength),
          _InfoRow(label: '경력', value: model.career),
          _InfoRow(label: '선호 시술', value: model.preferredTreatments.join(', ')),
          _InfoRow(label: '이미지', value: model.imageTags.join(', ')),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          AppTheme.spacing4,
          AppTheme.spacing3,
          AppTheme.spacing4,
          AppTheme.spacing3 + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.backgroundWhite,
          border: Border(top: BorderSide(color: AppTheme.borderGray)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: (_isSendingHeart || _heartSent) ? null : _sendHeart,
            icon: _isSendingHeart
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Icon(
                    _heartSent ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                  ),
            label: Text(
              _isSendingHeart
                  ? '보내는 중...'
                  : (_heartSent ? '하트를 보냈어요' : '하트 보내기'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.stitchPrimary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppTheme.stitchPrimary.withValues(alpha: 0.6),
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({required this.item});

  final ModelApplicationSearchItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurpleLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: AppTheme.primaryPurple),
              const SizedBox(width: AppTheme.spacing2),
              Text(
                '${item.date} · ${item.startTime}~${item.endTime}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryPurpleDark,
                ),
              ),
            ],
          ),
          if (item.keywords.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacing2),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: item.keywords.map((k) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundWhite,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    k,
                    style: const TextStyle(fontSize: 12, color: AppTheme.primaryPurpleDark),
                  ),
                );
              }).toList(),
            ),
          ],
          if (item.memo != null && item.memo!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacing2),
            Text(
              item.memo!,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
