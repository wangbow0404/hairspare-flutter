import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../services/notification_service.dart';
import '../../utils/error_handler.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// Next.js와 동일한 알림 설정 화면
class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  int _currentNavIndex = 0;
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;
  bool _isSaving = false;
  
  // 전체 알림 설정
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  
  // 알림 유형별 설정
  bool _jobAlerts = true;
  bool _messages = true;
  bool _scheduleReminders = true;
  bool _energyUpdates = true;
  bool _verificationStatus = true;
  bool _challengeNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final settings = await _notificationService.getNotificationSettings();
      setState(() {
        _pushEnabled = settings.pushEnabled;
        _emailEnabled = settings.emailEnabled;
        _jobAlerts = settings.jobAlerts;
        _messages = settings.messages;
        _scheduleReminders = settings.scheduleReminders;
        _energyUpdates = settings.energyUpdates;
        _verificationStatus = settings.verificationStatus;
        _challengeNotifications = settings.challengeNotifications;
      });
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(appException)),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleToggle(String key) async {
    setState(() {
      switch (key) {
        case 'pushEnabled':
          _pushEnabled = !_pushEnabled;
          break;
        case 'emailEnabled':
          _emailEnabled = !_emailEnabled;
          break;
        case 'jobAlerts':
          _jobAlerts = !_jobAlerts;
          break;
        case 'messages':
          _messages = !_messages;
          break;
        case 'scheduleReminders':
          _scheduleReminders = !_scheduleReminders;
          break;
        case 'energyUpdates':
          _energyUpdates = !_energyUpdates;
          break;
        case 'verificationStatus':
          _verificationStatus = !_verificationStatus;
          break;
        case 'challengeNotifications':
          _challengeNotifications = !_challengeNotifications;
          break;
      }
    });

    setState(() {
      _isSaving = true;
    });

    try {
      // API 호출하여 설정 저장
      final settings = NotificationSettings(
        pushEnabled: _pushEnabled,
        emailEnabled: _emailEnabled,
        jobAlerts: _jobAlerts,
        messages: _messages,
        scheduleReminders: _scheduleReminders,
        energyUpdates: _energyUpdates,
        verificationStatus: _verificationStatus,
        challengeNotifications: _challengeNotifications,
      );
      
      await _notificationService.updateNotificationSettings(settings);
    } catch (e) {
      // 롤백
      setState(() {
        switch (key) {
          case 'pushEnabled':
            _pushEnabled = !_pushEnabled;
            break;
          case 'emailEnabled':
            _emailEnabled = !_emailEnabled;
            break;
          case 'jobAlerts':
            _jobAlerts = !_jobAlerts;
            break;
          case 'messages':
            _messages = !_messages;
            break;
          case 'scheduleReminders':
            _scheduleReminders = !_scheduleReminders;
            break;
          case 'energyUpdates':
            _energyUpdates = !_energyUpdates;
            break;
          case 'verificationStatus':
            _verificationStatus = !_verificationStatus;
            break;
          case 'challengeNotifications':
            _challengeNotifications = !_challengeNotifications;
            break;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('설정 저장에 실패했습니다: ${e.toString()}'),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
          '알림 설정',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: AppTheme.spacing(AppTheme.spacing6),
        child: Column(
          children: [
            // 전체 알림 설정
            Container(
              padding: AppTheme.spacing(AppTheme.spacing4),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                border: Border.all(color: AppTheme.borderGray),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '전체 알림',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  // 푸시 알림
                  _NotificationToggleItem(
                    icon: IconMapper.icon('bell', size: 20, color: AppTheme.primaryPurple) ??
                        const Icon(Icons.notifications, size: 20, color: AppTheme.primaryPurple),
                    title: '푸시 알림',
                    subtitle: '앱 푸시 알림 받기',
                    value: _pushEnabled,
                    onToggle: () => _handleToggle('pushEnabled'),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  // 이메일 알림
                  _NotificationToggleItem(
                    icon: IconMapper.icon('mail', size: 20, color: AppTheme.primaryBlue) ??
                        const Icon(Icons.email, size: 20, color: AppTheme.primaryBlue),
                    title: '이메일 알림',
                    subtitle: '이메일로 알림 받기',
                    value: _emailEnabled,
                    onToggle: () => _handleToggle('emailEnabled'),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.spacing6),
            // 알림 유형별 설정
            Container(
              padding: AppTheme.spacing(AppTheme.spacing4),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                border: Border.all(color: AppTheme.borderGray),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '알림 유형',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  // 공고 알림
                  _NotificationToggleItem(
                    icon: IconMapper.icon('zap', size: 20, color: AppTheme.yellow400) ??
                        const Icon(Icons.flash_on, size: 20, color: AppTheme.yellow400),
                    title: '공고 알림',
                    subtitle: '새로운 공고 및 매칭 알림',
                    value: _jobAlerts,
                    enabled: _pushEnabled || _emailEnabled,
                    onToggle: () => _handleToggle('jobAlerts'),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  // 메시지 알림
                  _NotificationToggleItem(
                    icon: IconMapper.icon('messagecircle', size: 20, color: AppTheme.primaryGreen) ??
                        const Icon(Icons.message, size: 20, color: AppTheme.primaryGreen),
                    title: '메시지 알림',
                    subtitle: '채팅 메시지 알림',
                    value: _messages,
                    enabled: _pushEnabled || _emailEnabled,
                    onToggle: () => _handleToggle('messages'),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  // 스케줄 알림
                  _NotificationToggleItem(
                    icon: IconMapper.icon('calendar', size: 20, color: AppTheme.primaryBlue) ??
                        const Icon(Icons.calendar_today, size: 20, color: AppTheme.primaryBlue),
                    title: '스케줄 알림',
                    subtitle: '스케줄 및 리마인더 알림',
                    value: _scheduleReminders,
                    enabled: _pushEnabled || _emailEnabled,
                    onToggle: () => _handleToggle('scheduleReminders'),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  // 에너지 알림
                  _NotificationToggleItem(
                    icon: IconMapper.icon('zap', size: 20, color: AppTheme.primaryPurple) ??
                        const Icon(Icons.bolt, size: 20, color: AppTheme.primaryPurple),
                    title: '에너지 알림',
                    subtitle: '에너지 충전/사용 알림',
                    value: _energyUpdates,
                    enabled: _pushEnabled || _emailEnabled,
                    onToggle: () => _handleToggle('energyUpdates'),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  // 인증 상태 알림
                  _NotificationToggleItem(
                    icon: IconMapper.icon('shield', size: 20, color: AppTheme.primaryPurpleDarker) ??
                        const Icon(Icons.shield, size: 20, color: AppTheme.primaryPurpleDarker),
                    title: '인증 상태 알림',
                    subtitle: '인증 승인/거절 알림',
                    value: _verificationStatus,
                    enabled: _pushEnabled || _emailEnabled,
                    onToggle: () => _handleToggle('verificationStatus'),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  // 챌린지 알림
                  _NotificationToggleItem(
                    icon: IconMapper.icon('video', size: 20, color: AppTheme.primaryPurple) ??
                        const Icon(Icons.video_library, size: 20, color: AppTheme.primaryPurple),
                    title: '챌린지 알림',
                    subtitle: '구독한 크리에이터의 새 영상 알림',
                    value: _challengeNotifications,
                    enabled: _pushEnabled || _emailEnabled,
                    onToggle: () => _handleToggle('challengeNotifications'),
                  ),
                ],
              ),
            ),
            if (_isSaving) ...[
              SizedBox(height: AppTheme.spacing4),
              Center(
                child: Text(
                  '저장 중...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          
          // 네비게이션 처리
          switch (index) {
            case 0:
              // 홈으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SpareHomeScreen()),
              );
              break;
            case 1:
              // 결제로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PaymentScreen()),
              );
              break;
            case 2:
              // 찜으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
              break;
            case 3:
              // 마이(프로필)로 이동
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

class _NotificationToggleItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final VoidCallback onToggle;

  const _NotificationToggleItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.enabled = true,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        SizedBox(width: AppTheme.spacing3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: AppTheme.spacing1 / 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value && enabled,
          onChanged: enabled ? (_) => onToggle() : null,
          activeColor: AppTheme.primaryBlue,
        ),
      ],
    );
  }
}
