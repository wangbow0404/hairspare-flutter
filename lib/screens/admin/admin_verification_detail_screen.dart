import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_table_card.dart';

/// M2. 인증 심사 상세 — 제출정보 + OCR/NTS 증빙 뷰 (Stitch §3 M2)
class AdminVerificationDetailScreen extends StatefulWidget {
  const AdminVerificationDetailScreen({
    super.key,
    required this.verificationId,
    this.initialData,
  });

  final String verificationId;
  final Map<String, dynamic>? initialData;

  @override
  State<AdminVerificationDetailScreen> createState() =>
      _AdminVerificationDetailScreenState();
}

class _AdminVerificationDetailScreenState
    extends State<AdminVerificationDetailScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _detail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _detail = widget.initialData;
      _isLoading = false;
    }
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await _adminService.getVerificationDetail(widget.verificationId);
      if (mounted) setState(() { _detail = data; _isLoading = false; });
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

  Future<void> _approve() async {
    final reason = await AdminActionDialog.show(
      context,
      title: '인증 승인',
      confirmLabel: '승인',
      summary: '${_detail?['userName']} · ${_detail?['typeLabel']}',
    );
    if (reason == null || !mounted) return;
    await _adminService.approveVerification(widget.verificationId, note: reason);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('인증이 승인되었습니다')));
    context.pop();
  }

  Future<void> _reject() async {
    final reason = await AdminActionDialog.show(
      context,
      title: '인증 반려',
      confirmLabel: '반려',
      summary: '${_detail?['userName']} · ${_detail?['typeLabel']}',
      isDanger: true,
    );
    if (reason == null || !mounted) return;
    await _adminService.rejectVerification(widget.verificationId, reason: reason);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('인증이 반려되었습니다')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _detail == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_detail == null) {
      return Center(
        child: FilledButton(onPressed: _load, child: const Text('다시 시도')),
      );
    }

    final detail = _detail!;
    final submitted = detail['submitted'] as Map<String, dynamic>? ?? {};
    final ocr = detail['ocr'] as Map<String, dynamic>? ?? {};
    final nts = detail['ntsValidation'] as Map<String, dynamic>? ?? {};
    final isPending = detail['status'] == 'pending';
    final ntsMatch = nts['match'] == true;

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
                          '인증 심사 · ${detail['typeLabel']}',
                          style: AdminStitchTheme.pageTitleForWidth(constraints.maxWidth),
                        ),
                        Text(
                          '${detail['userName']} · ${_formatDate(detail['submittedAt']?.toString())}',
                          style: AdminStitchTheme.pageSubtitle.copyWith(fontSize: 13),
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (isPending) ...[
                FilledButton(
                  onPressed: _approve,
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.green600),
                  child: const Text('승인'),
                ),
                const SizedBox(width: AppTheme.spacing2),
                OutlinedButton(
                  onPressed: _reject,
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.urgentRed),
                  child: const Text('반려'),
                ),
              ],
            ],
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 768;
              final left = AdminVerificationSubmissionPanel(
                submitted: submitted,
                userEmail: detail['userEmail']?.toString(),
                userRole: detail['userRole']?.toString(),
              );
              final right = AdminVerificationEvidencePanel(
                ocr: ocr,
                nts: nts,
                ntsMatch: ntsMatch,
              );
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: left),
                    const SizedBox(width: AppTheme.spacing4),
                    Expanded(child: right),
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

class AdminVerificationSubmissionPanel extends StatelessWidget {
  const AdminVerificationSubmissionPanel({
    super.key,
    required this.submitted,
    this.userEmail,
    this.userRole,
  });

  final Map<String, dynamic> submitted;
  final String? userEmail;
  final String? userRole;

  @override
  Widget build(BuildContext context) {
    return AdminTableCard(
      padding: const EdgeInsets.all(AppTheme.spacing6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('제출 정보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppTheme.spacing4),
          _InfoRow(label: '이메일', value: userEmail ?? '-'),
          _InfoRow(label: '역할', value: userRole ?? '-'),
          const Divider(height: AppTheme.spacing6),
          _InfoRow(label: '사업자번호', value: submitted['businessNumber']?.toString() ?? '-'),
          _InfoRow(label: '상호', value: submitted['businessName']?.toString() ?? '-'),
          _InfoRow(label: '대표자', value: submitted['representative']?.toString() ?? '-'),
          _InfoRow(label: '주소', value: submitted['address']?.toString() ?? '-'),
        ],
      ),
    );
  }
}

class AdminVerificationEvidencePanel extends StatelessWidget {
  const AdminVerificationEvidencePanel({
    super.key,
    required this.ocr,
    required this.nts,
    required this.ntsMatch,
  });

  final Map<String, dynamic> ocr;
  final Map<String, dynamic> nts;
  final bool ntsMatch;

  @override
  Widget build(BuildContext context) {
    return AdminTableCard(
      padding: const EdgeInsets.all(AppTheme.spacing6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('증빙 · OCR · NTS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppTheme.spacing4),
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.adminPurple50,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppTheme.adminPurple100),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description, size: 48, color: AppTheme.textTertiary),
                SizedBox(height: AppTheme.spacing2),
                Text('사업자등록증 이미지', style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          const Text('OCR 추출값', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: AppTheme.spacing2),
          _InfoRow(label: '사업자번호', value: ocr['businessNumber']?.toString() ?? '-'),
          _InfoRow(label: '상호', value: ocr['businessName']?.toString() ?? '-'),
          _InfoRow(label: '대표자', value: ocr['representative']?.toString() ?? '-'),
          _InfoRow(label: '신뢰도', value: '${((ocr['confidence'] as num? ?? 0) * 100).toStringAsFixed(0)}%'),
          const SizedBox(height: AppTheme.spacing4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacing4),
            decoration: BoxDecoration(
              color: (ntsMatch ? AppTheme.green50 : AppTheme.red50),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: ntsMatch ? AppTheme.green200 : AppTheme.red200),
            ),
            child: Row(
              children: [
                Icon(
                  ntsMatch ? Icons.check_circle : Icons.error,
                  color: ntsMatch ? AppTheme.green600 : AppTheme.urgentRed,
                ),
                const SizedBox(width: AppTheme.spacing3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NTS 검증: ${nts['statusLabel'] ?? (ntsMatch ? '일치' : '불일치')}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: ntsMatch ? AppTheme.green700 : AppTheme.urgentRed,
                        ),
                      ),
                      Text(
                        '검증 시각: ${nts['checkedAt'] ?? '-'}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
