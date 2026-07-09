import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../mocks/mock_auth_data.dart';
import '../../models/hair_model.dart';
import '../../models/match_profile.dart';
import '../../models/model_application_search_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../services/matching_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_bar_navigation.dart';
import '../../utils/error_handler.dart';
import '../../utils/messaging_audience.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/notification_bell.dart';

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
  static const double _heroHeight = 300;
  static const double _cardOverlap = 56;

  bool _isSendingHeart = false;
  bool _heartSent = false;

  Future<void> _sendHeart() async {
    if (_isSendingHeart || _heartSent) return;
    setState(() => _isSendingHeart = true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser ??
          MockAuthData.spareUser();
      // fromProfile은 서버가 실제로 쓰지 않고(targetModelId만 전송됨) 서버가
      // 직접 User/SpareExtProfile을 조회해 구성하므로, 여기서 포트폴리오·
      // 디자이너 프로필을 미리 불러올 필요가 없다(불필요한 네트워크 왕복 제거).
      final fromProfile = MatchProfile(
        id: user.id,
        role: 'spare',
        displayName: user.name ?? user.username,
        subtitle: '',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppTheme.spacing3 + 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: _cardOverlap),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    height: _heroHeight,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppNetworkImage(
                          imageUrl: model.primaryImage,
                          fit: BoxFit.cover,
                          fallbackIcon: Icons.person_outline,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.35),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.25),
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.paddingOf(context).top + AppTheme.spacing2,
                          left: AppTheme.spacing4,
                          right: AppTheme.spacing4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _GlassIconButton(
                                icon: Icons.arrow_back_ios_new,
                                onTap: () => Navigator.maybePop(context),
                              ),
                              Row(
                                children: [
                                  _GlassIconButton(
                                    icon: Icons.search,
                                    onTap: () => AppBarNavigation.pushSearch(context),
                                  ),
                                  const SizedBox(width: AppTheme.spacing2),
                                  _GlassIconButton(
                                    icon: Icons.chat_bubble_outline,
                                    onTap: () => AppBarNavigation.pushMessages(context),
                                    badge: context.watch<ChatProvider>().totalUnreadCount > 0,
                                  ),
                                  const SizedBox(width: AppTheme.spacing2),
                                  _GlassIconButton.custom(
                                    child: NotificationBell(
                                      role: MessagingAudience.resolve(context),
                                      iconColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: AppTheme.spacing4,
                    right: AppTheme.spacing4,
                    bottom: -_cardOverlap,
                    child: _NameOverlapCard(model: model),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacing4,
                AppTheme.spacing2,
                AppTheme.spacing4,
                0,
              ),
              child: _DetailsCard(model: model, item: widget.item),
            ),
            const SizedBox(height: AppTheme.spacing2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
              child: _MetadataGrid(model: model),
            ),
          ],
        ),
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
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: (_isSendingHeart || _heartSent)
                  ? null
                  : AppTheme.stitchHeroGradient,
              color: (_isSendingHeart || _heartSent)
                  ? AppTheme.stitchPrimary.withValues(alpha: 0.6)
                  : null,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            ),
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
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 히어로 이미지 위에 뜨는 반투명 원형 아이콘 버튼.
class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onTap, this.badge = false})
      : child = null;

  const _GlassIconButton.custom({required this.child})
      : icon = null,
        onTap = null,
        badge = false;

  final IconData? icon;
  final VoidCallback? onTap;
  final bool badge;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final content = child ??
        Icon(icon, size: 20, color: Colors.white);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (onTap != null)
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: Center(child: content),
              ),
            )
          else
            Center(child: content),
          if (badge)
            const Positioned(
              top: 9,
              right: 9,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppTheme.urgentRed,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(width: 8, height: 8),
              ),
            ),
        ],
      ),
    );
  }
}

/// 히어로 이미지 아래로 살짝 겹쳐지는 이름 카드 — 이름·나이·위치만 표시.
/// 소개·태그·예약시간처럼 길이가 들쭉날쭉한 내용은 여기 넣지 않는다 —
/// 카드 높이가 늘어나 사진을 다 가려버리는 문제가 있었음(테스트 데이터처럼
/// 소개글·메모가 길 때 카드가 히어로 이미지 전체를 덮어버렸었다).
class _NameOverlapCard extends StatelessWidget {
  const _NameOverlapCard({required this.model});

  final HairModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing5,
        vertical: AppTheme.spacing4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radius2xl),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Flexible(
            child: Text(
              model.name.isEmpty ? '모델' : model.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          if (model.age > 0) ...[
            const SizedBox(width: AppTheme.spacing2),
            Text(
              '${model.age}',
              style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
          ],
          if (model.region.isNotEmpty) ...[
            const SizedBox(width: AppTheme.spacing3),
            const Icon(Icons.place_outlined, size: 15, color: AppTheme.textTertiary),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                model.region,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 예약 가능 시간 + 모델이 직접 적은 멘트(메모) — 사진과 안 겹치는 일반 카드.
class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.model, required this.item});

  final HairModel model;
  final ModelApplicationSearchItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing5),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radius2xl),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryPurpleLight,
                  AppTheme.primaryPurpleLight.withValues(alpha: 0.0),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: const Border(
                left: BorderSide(color: AppTheme.primaryPurple, width: 4),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundWhite,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.schedule, size: 18, color: AppTheme.primaryPurple),
                ),
                const SizedBox(width: AppTheme.spacing3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '예약 가능 시간',
                        style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.date} · ${item.startTime}~${item.endTime}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (item.memo != null && item.memo!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacing3),
            Text(
              item.memo!,
              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
            ),
          ],
        ],
      ),
    );
  }
}

/// 기장·경력·선호시술·이미지를 2x2 그리드로 보여주는 메타데이터 카드들.
class _MetadataGrid extends StatelessWidget {
  const _MetadataGrid({required this.model});

  final HairModel model;

  @override
  Widget build(BuildContext context) {
    final items = <_MetaItem>[
      _MetaItem(Icons.straighten, '기장', model.hairLength),
      _MetaItem(Icons.workspace_premium, '경력', model.career),
      _MetaItem(
        Icons.content_cut,
        '선호 시술',
        model.preferredTreatments.join(', '),
      ),
      _MetaItem(
        Icons.face_retouching_natural,
        '이미지',
        model.imageTags.join(', '),
      ),
    ].where((m) => m.value.isNotEmpty).toList();

    if (items.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.spacing3,
        mainAxisSpacing: AppTheme.spacing3,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          decoration: BoxDecoration(
            color: AppTheme.backgroundWhite,
            borderRadius: BorderRadius.circular(AppTheme.radius2xl),
            border: Border.all(color: AppTheme.borderGray),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(item.icon, color: AppTheme.primaryPurple.withValues(alpha: 0.6), size: 24),
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                item.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetaItem {
  const _MetaItem(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
}
