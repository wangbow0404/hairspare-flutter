import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../services/subscription_service.dart';
import '../../utils/error_handler.dart';
import '../../models/subscription.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// 구독한 크리에이터 목록 화면
class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  int _currentNavIndex = 3;
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<Creator> _creators = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final creators = await _subscriptionService.getMySubscriptions();
      setState(() {
        _creators = creators;
      });
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      print('구독 목록 로드 오류: ${appException.toString()}');
      // API 실패 시 빈 리스트 유지
      setState(() {
        _creators = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleUnsubscribe(String creatorId) async {
    try {
      await _subscriptionService.unsubscribe(creatorId);
      await _loadSubscriptions(); // 목록 새로고침

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('구독이 취소되었습니다'),
            backgroundColor: AppTheme.primaryGreen,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('구독 취소 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textSecondary) ??
              const Icon(Icons.arrow_back_ios, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '구독한 크리에이터',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _creators.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconMapper.icon('users', size: 64, color: AppTheme.textTertiary) ??
                          const Icon(Icons.people_outline, size: 64, color: AppTheme.textTertiary),
                      SizedBox(height: AppTheme.spacing4),
                      Text(
                        '구독한 크리에이터가 없습니다',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing2),
                      Text(
                        '챌린지에서 관심있는 크리에이터를 구독해보세요!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSubscriptions,
                  child: ListView.builder(
                    padding: EdgeInsets.all(AppTheme.spacing3),
                    itemCount: _creators.length,
                    itemBuilder: (context, index) {
                      final creator = _creators[index];
                      return _CreatorListItem(
                        creator: creator,
                        onUnsubscribe: () => _handleUnsubscribe(creator.id),
                      );
                    },
                  ),
                ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SpareHomeScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PaymentScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}

/// 크리에이터 리스트 아이템
class _CreatorListItem extends StatelessWidget {
  final Creator creator;
  final VoidCallback onUnsubscribe;

  const _CreatorListItem({
    required this.creator,
    required this.onUnsubscribe,
  });

  String _formatNumber(int num) {
    if (num >= 10000) {
      return '${(num / 10000).toStringAsFixed(1)}만';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}천';
    }
    return num.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing2),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryPurple,
                AppTheme.primaryBlue,
              ],
            ),
            borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
          ),
          child: creator.avatar != null
              ? ClipRRect(
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                  child: Image.network(
                    creator.avatar!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: IconMapper.icon('user', size: 24, color: Colors.white) ??
                            const Icon(Icons.person, size: 24, color: Colors.white),
                      );
                    },
                  ),
                )
              : Center(
                  child: IconMapper.icon('user', size: 24, color: Colors.white) ??
                      const Icon(Icons.person, size: 24, color: Colors.white),
                ),
        ),
        title: Text(
          creator.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppTheme.spacing1),
            Row(
              children: [
                Text(
                  '구독자 ${_formatNumber(creator.subscriberCount)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(width: AppTheme.spacing2),
                Text(
                  '영상 ${creator.videoCount}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: TextButton(
          onPressed: onUnsubscribe,
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.urgentRed,
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacing3,
              vertical: AppTheme.spacing1,
            ),
          ),
          child: const Text(
            '구독 취소',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
