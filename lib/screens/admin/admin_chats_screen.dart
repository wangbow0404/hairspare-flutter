import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router/app_routes.dart';
import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_stitch_list_cards.dart';
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// 관리자 고객센터 채팅 목록
class AdminChatsScreen extends StatefulWidget {
  const AdminChatsScreen({super.key});

  @override
  State<AdminChatsScreen> createState() => _AdminChatsScreenState();
}

class _AdminChatsScreenState extends State<AdminChatsScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final chats = await _adminService.getAdminChats();
      if (mounted) {
        setState(() {
          _chats = chats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ErrorHandler.getUserFriendlyMessage(
                ErrorHandler.handleException(e),
              ),
            ),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  String _formatTime(String? value) {
    if (value == null || value.isEmpty) return '';
    try {
      return DateFormat('M.d HH:mm', 'ko_KR')
          .format(DateTime.parse(value).toLocal());
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminStitchListScreenShell(
      header: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminStitchPageHeader(
            title: '고객센터 채팅',
            subtitle: '회원과 나눈 1:1 채팅 목록입니다',
          ),
          SizedBox(height: AdminStitchTheme.sectionGap),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AdminStitchListStateSliver.loading();
    }
    if (_chats.isEmpty) {
      return const AdminStitchListStateSliver.empty(
        emptyMessage: '아직 채팅 내역이 없습니다\n회원 상세에서 채팅하기를 눌러 시작하세요',
        emptyIcon: Icons.chat_bubble_outline,
      );
    }
    return SliverPadding(
      padding: AdminStitchListScreenShell.listPadding(context),
      sliver: SliverList.separated(
        itemCount: _chats.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AdminStitchTheme.sectionGap),
        itemBuilder: (_, index) {
          final chat = _chats[index] as Map<String, dynamic>;
          final name = chat['spareName']?.toString() ?? '회원';
          final role = chat['roleLabel']?.toString() ?? '';
          final last = chat['lastMessage'] as Map<String, dynamic>?;
          final preview = last?['content']?.toString() ?? '대화 시작';
          final time = _formatTime(
            last?['createdAt']?.toString() ?? chat['lastMessageAt']?.toString(),
          );
          final chatId =
              chat['chatId']?.toString() ?? chat['id']?.toString() ?? '';

          return AdminStitchSimpleListCard(
            title: name,
            subtitle: role.isNotEmpty ? '$role · $preview' : preview,
            icon: Icons.chat_bubble_outline,
            iconColor: AdminStitchTheme.primary,
            trailing: time.isNotEmpty
                ? Text(
                    time,
                    style: AdminStitchTheme.labelSm.copyWith(
                      color: AdminStitchTheme.textSecondary,
                    ),
                  )
                : null,
            onTap: chatId.isEmpty
                ? null
                : () => context.push(
                      AppRoutes.adminChat(chatId),
                      extra: {
                        'id': chat['spareId'],
                        'name': name,
                        'roleLabel': role,
                      },
                    ),
          );
        },
      ),
    );
  }
}
