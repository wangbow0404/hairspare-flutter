import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_table_card.dart';

/// M12. 신고/제재 케이스 상세 — 케이스정보 + 채팅 로그 감사 뷰
class AdminReportDetailScreen extends StatefulWidget {
  const AdminReportDetailScreen({
    super.key,
    required this.reportId,
    this.initialData,
  });

  final String reportId;
  final Map<String, dynamic>? initialData;

  @override
  State<AdminReportDetailScreen> createState() => _AdminReportDetailScreenState();
}

class _AdminReportDetailScreenState extends State<AdminReportDetailScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _report;
  List<dynamic> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _report = widget.initialData;
    }
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final report = await _adminService.getReportDetail(widget.reportId);
      final chatId = report['chatId']?.toString();
      List<dynamic> messages = [];
      if (chatId != null && chatId.isNotEmpty) {
        final transcript = await _adminService.getChatTranscript(chatId);
        messages = transcript['messages'] ?? [];
      }
      if (mounted) {
        setState(() {
          _report = report;
          _messages = messages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(String? v) {
    if (v == null) return '-';
    try {
      return DateFormat('yyyy.MM.dd HH:mm').format(DateTime.parse(v).toLocal());
    } catch (_) {
      return v;
    }
  }

  Future<void> _resolve(String action) async {
    final labels = {'dismiss': '기각', 'warn': '경고', 'suspend': '정지', 'ban': '영구정지'};
    final reason = await AdminActionDialog.show(
      context,
      title: '신고 ${labels[action]}',
      confirmLabel: labels[action] ?? action,
      summary: _report?['reportedName']?.toString(),
      isDanger: action != 'dismiss',
    );
    if (reason == null || !mounted) return;
    try {
      await _adminService.resolveReport(
        widget.reportId,
        action: action,
        reason: reason,
        durationDays: action == 'suspend' ? 7 : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${labels[action]} 처리되었습니다 (감사 로그 기록)')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _report == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_report == null) {
      return Center(child: FilledButton(onPressed: _load, child: const Text('다시 시도')));
    }

    final report = _report!;
    final isOpen = report['status'] == 'open' || report['status'] == 'in_review';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AdminStitchTheme.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              const SizedBox(width: AppTheme.spacing1),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report['categoryLabel']?.toString() ?? '신고 케이스',
                          style: AdminStitchTheme.pageTitleForWidth(constraints.maxWidth),
                        ),
                        Text(
                          '${report['reporterName']} → ${report['reportedName']} · ${_formatDate(report['createdAt']?.toString())}',
                          style: AdminStitchTheme.pageSubtitle.copyWith(fontSize: 13),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: AppTheme.spacing2),
              _PriorityChip(label: report['priorityLabel']?.toString() ?? ''),
            ],
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 768;
              final left = AdminReportCasePanel(
                report: report,
                isOpen: isOpen,
                onResolve: _resolve,
                formatDate: _formatDate,
              );
              final right = AdminReportChatLogPanel(
                messages: _messages,
                formatDate: _formatDate,
              );
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: left),
                    const SizedBox(width: AppTheme.spacing4),
                    Expanded(flex: 3, child: right),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  left,
                  const SizedBox(height: AppTheme.spacing4),
                  right,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class AdminReportCasePanel extends StatelessWidget {
  const AdminReportCasePanel({
    super.key,
    required this.report,
    required this.isOpen,
    required this.onResolve,
    required this.formatDate,
  });

  final Map<String, dynamic> report;
  final bool isOpen;
  final void Function(String action) onResolve;
  final String Function(String?) formatDate;

  @override
  Widget build(BuildContext context) {
    return AdminTableCard(
      padding: const EdgeInsets.all(AppTheme.spacing6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('케이스 정보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppTheme.spacing4),
          _ReportInfoRow(label: '상태', value: report['statusLabel']?.toString() ?? '-'),
          _ReportInfoRow(label: '신고자', value: report['reporterName']?.toString() ?? '-'),
          _ReportInfoRow(label: '피신고', value: report['reportedName']?.toString() ?? '-'),
          _ReportInfoRow(label: '유형', value: report['categoryLabel']?.toString() ?? '-'),
          _ReportInfoRow(label: '접수일', value: formatDate(report['createdAt']?.toString())),
          const SizedBox(height: AppTheme.spacing3),
          Text(
            report['summary']?.toString() ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            report['description']?.toString() ?? '',
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          if (isOpen) ...[
            const SizedBox(height: AppTheme.spacing4),
            const Divider(),
            const SizedBox(height: AppTheme.spacing3),
            const Text('처리 액션', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppTheme.spacing2),
            Wrap(
              spacing: AppTheme.spacing2,
              runSpacing: AppTheme.spacing2,
              children: [
                FilledButton(onPressed: () => onResolve('dismiss'), child: const Text('기각')),
                FilledButton(onPressed: () => onResolve('warn'), child: const Text('경고')),
                FilledButton(
                  onPressed: () => onResolve('suspend'),
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.orange600),
                  child: const Text('정지'),
                ),
                FilledButton(
                  onPressed: () => onResolve('ban'),
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.urgentRed),
                  child: const Text('영구정지'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class AdminReportChatLogPanel extends StatelessWidget {
  const AdminReportChatLogPanel({
    super.key,
    required this.messages,
    required this.formatDate,
  });

  final List<dynamic> messages;
  final String Function(String?) formatDate;

  @override
  Widget build(BuildContext context) {
    return AdminTableCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.adminPurple50, AppTheme.adminPink50],
              ),
              border: Border(bottom: BorderSide(color: AppTheme.adminPurple100)),
            ),
            child: const Row(
              children: [
                Icon(Icons.forum, size: 18, color: AppTheme.primaryPurple),
                SizedBox(width: AppTheme.spacing2),
                Text('채팅 로그 감사 뷰', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          if (messages.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppTheme.spacing8),
              child: Center(child: Text('채팅 로그가 없습니다')),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppTheme.spacing4),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index] as Map<String, dynamic>;
                final violation = msg['contactViolation'] == true;
                return Container(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacing3),
                  padding: const EdgeInsets.all(AppTheme.spacing3),
                  decoration: BoxDecoration(
                    color: violation ? AppTheme.red50 : AppTheme.adminPurple50.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(
                      color: violation ? AppTheme.red200 : AppTheme.adminPurple100,
                      width: violation ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            msg['senderName']?.toString() ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          if (violation) ...[
                            const SizedBox(width: AppTheme.spacing2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.urgentRed,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '연락처 위반',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            formatDate(msg['createdAt']?.toString()),
                            style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacing2),
                      Text(msg['body']?.toString() ?? '', style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isHigh = label == '긴급';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing3, vertical: AppTheme.spacing1),
      decoration: BoxDecoration(
        color: (isHigh ? AppTheme.urgentRed : AppTheme.orange600).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isHigh ? AppTheme.urgentRed : AppTheme.orange600,
        ),
      ),
    );
  }
}

class _ReportInfoRow extends StatelessWidget {
  const _ReportInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing2),
      child: Row(
        children: [
          SizedBox(width: 64, child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
