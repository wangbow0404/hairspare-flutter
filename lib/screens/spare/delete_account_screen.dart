import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/shared_app_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../services/auth_service.dart';
import '../../utils/error_handler.dart';
import '../../core/router/app_navigation.dart';

/// Next.js와 동일한 계정 삭제 화면
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final AuthService _authService = AuthService();
  String _step = 'warning'; // warning, final
  final _passwordController = TextEditingController();
  bool _isLoading = true;
  bool _isDeleting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    setState(() {
      _isDeleting = true;
      _error = null;
    });

    try {
      // API 호출하여 계정 삭제
      await _authService.deleteAccount(
        password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      );
      
      // 로그아웃 후 로그인 화면으로 이동
      if (mounted) {
        AppNavigation.goSpareLogin(context);
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      setState(() {
        _error = ErrorHandler.getUserFriendlyMessage(appException);
        _isDeleting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(appException)),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SharedAppBar(title: '계정 삭제'),
      body: SingleChildScrollView(
        padding: AppTheme.spacing(AppTheme.spacing6),
        child: _step == 'warning'
            ? Column(
                children: [
                  // 경고 메시지
                  Container(
                    padding: AppTheme.spacing(AppTheme.spacing6),
                    decoration: BoxDecoration(
                      color: AppTheme.urgentRedLight,
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      border: Border.all(color: AppTheme.urgentRed.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconMapper.icon('alerttriangle', size: 24, color: AppTheme.urgentRed) ??
                                const Icon(Icons.warning, size: 24, color: AppTheme.urgentRed),
                            const SizedBox(width: AppTheme.spacing3),
                            Expanded(
                              child: Text(
                                '계정 삭제 전 확인사항',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.urgentRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          '계정을 삭제하면 다음 정보가 영구적으로 삭제되며 복구할 수 없습니다.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                            color: AppTheme.urgentRed.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                        ...[
                          '프로필 정보 및 인증 정보',
                          '에너지 잔액 및 거래 내역',
                          '스케줄 및 지원 내역',
                          '메시지 및 채팅 내역',
                          '후기 및 평가 내역',
                        ].map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppTheme.spacing2),
                            child: Row(
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    color: AppTheme.urgentRed,
                                    fontSize: 14,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 14,
                                      color: AppTheme.urgentRed.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing6),
                  // 안내사항
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
                          '안내사항',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                        ...[
                          '진행 중인 스케줄이 있는 경우, 스케줄 완료 후 삭제를 진행해주세요.',
                          '미정산된 에너지가 있는 경우, 정산 완료 후 삭제를 진행해주세요.',
                          '계정 삭제 후 30일 이내에 재가입할 수 없습니다.',
                        ].map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppTheme.spacing2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    color: AppTheme.textTertiary,
                                    fontSize: 14,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing6),
                  // 계속하기 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _step = 'final';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.urgentRed,
                        foregroundColor: Colors.white,
                        padding: AppTheme.spacing(AppTheme.spacing3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconMapper.icon('trash2', size: 20, color: Colors.white) ??
                              const Icon(Icons.delete, size: 20, color: Colors.white),
                          const SizedBox(width: AppTheme.spacing2),
                          Text(
                            '계속하기',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  // 취소 버튼
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.borderGray),
                        padding: AppTheme.spacing(AppTheme.spacing3),
                      ),
                      child: Text(
                        '취소',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textGray700,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  // 최종 확인
                  Container(
                    padding: AppTheme.spacing(AppTheme.spacing6),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundWhite,
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      border: Border.all(color: AppTheme.urgentRed.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        IconMapper.icon('alerttriangle', size: 64, color: AppTheme.urgentRed) ??
                            const Icon(Icons.warning, size: 64, color: AppTheme.urgentRed),
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          '정말 계정을 삭제하시겠습니까?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.spacing2),
                        Text(
                          '이 작업은 되돌릴 수 없습니다. 모든 데이터가 영구적으로 삭제됩니다.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing6),
                  if (_error != null)
                    Container(
                      padding: AppTheme.spacing(AppTheme.spacing3),
                      decoration: BoxDecoration(
                        color: AppTheme.urgentRedLight,
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                        border: Border.all(color: AppTheme.urgentRed.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          IconMapper.icon('xcircle', size: 20, color: AppTheme.urgentRed) ??
                              const Icon(Icons.error, size: 20, color: AppTheme.urgentRed),
                          const SizedBox(width: AppTheme.spacing2),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.urgentRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_error != null) const SizedBox(height: AppTheme.spacing4),
                  // 최종 확인 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isDeleting ? null : _handleDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.urgentRed,
                        foregroundColor: Colors.white,
                        padding: AppTheme.spacing(AppTheme.spacing3),
                      ),
                      child: _isDeleting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconMapper.icon('trash2', size: 20, color: Colors.white) ??
                                    const Icon(Icons.delete, size: 20, color: Colors.white),
                                const SizedBox(width: AppTheme.spacing2),
                                Text(
                                  '확인',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  // 취소 버튼
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isDeleting
                          ? null
                          : () {
                              AppNavigation.goSpareHome(context);
                            },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.borderGray),
                        padding: AppTheme.spacing(AppTheme.spacing3),
                      ),
                      child: Text(
                        '취소',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textGray700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
