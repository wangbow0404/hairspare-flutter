import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';
import '../../utils/app_date_picker.dart';
import '../common/glass_modal.dart';

/// 샵 취소 사유·일정 변경 요청 결과.
class ShopCancelReasonResult {
  const ShopCancelReasonResult({
    required this.cancelReason,
    this.rescheduleDate,
  });

  final String? cancelReason;
  final DateTime? rescheduleDate;

  bool get isRescheduleRequest => rescheduleDate != null;
}

/// 샵 스케줄 취소 사유 입력 (GlassModal).
abstract final class ShopScheduleCancelReasonSheet {
  ShopScheduleCancelReasonSheet._();

  static Future<ShopCancelReasonResult?> show({
    required BuildContext context,
    required String scheduleId,
  }) {
    return showDialog<ShopCancelReasonResult>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _ShopScheduleCancelReasonDialog(scheduleId: scheduleId),
    );
  }
}

class _ShopScheduleCancelReasonDialog extends StatefulWidget {
  const _ShopScheduleCancelReasonDialog({required this.scheduleId});

  final String scheduleId;

  @override
  State<_ShopScheduleCancelReasonDialog> createState() =>
      _ShopScheduleCancelReasonDialogState();
}

class _ShopScheduleCancelReasonDialogState
    extends State<_ShopScheduleCancelReasonDialog> {
  static const List<String> _presetReasons = [
    '일정 변경',
    '샵 사정 (영업일/인력 등)',
    '스페어 사정 (개인 일정 등)',
    '스페어 노쇼/불참',
    '기타',
  ];

  String _selectedReason = _presetReasons.first;
  final TextEditingController _otherReasonController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  DateTime? _rescheduleDate;

  @override
  void dispose() {
    _otherReasonController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _pickRescheduleDate() async {
    final picked = await showAppDatePicker(
      context,
      initialDate: _rescheduleDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _rescheduleDate = picked);
  }

  String? _buildReason() {
    String reason = _selectedReason == '기타' &&
            _otherReasonController.text.trim().isNotEmpty
        ? _otherReasonController.text.trim()
        : _selectedReason;
    if (_selectedReason == '일정 변경' && _rescheduleDate != null) {
      reason = '$reason (변경 희망일: ${DateFormat('yyyy-MM-dd').format(_rescheduleDate!)})';
    }
    final detail = _detailController.text.trim();
    if (detail.isNotEmpty) {
      reason = '$reason - $detail';
    }
    return reason.isEmpty ? null : reason;
  }

  void _submit() {
    if (_selectedReason == '일정 변경' && _rescheduleDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('변경 희망일을 선택해 주세요.'),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
      return;
    }
    final reason = _buildReason();
    if (_selectedReason != '일정 변경' &&
        (reason == null || reason.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('취소 사유를 입력해 주세요.'),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      ShopCancelReasonResult(
        cancelReason: reason,
        rescheduleDate:
            _selectedReason == '일정 변경' ? _rescheduleDate : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassModal(
      onDismiss: () => Navigator.pop(context),
      child: GlassModalPanel(
        width: 360,
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassModalHeader(
                title: '스케줄 취소',
                onClose: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
              Text(
                '취소 사유를 선택하거나 입력해 주세요. '
                '일정 변경은 취소 대신 변경 요청으로 보낼 수 있습니다.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedReason,
                decoration: InputDecoration(
                  labelText: '취소 사유',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
                items: _presetReasons
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedReason = v);
                },
              ),
              if (_selectedReason == '일정 변경') ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickRescheduleDate,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.borderGray),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _rescheduleDate != null
                              ? DateFormat('yyyy년 M월 d일')
                                  .format(_rescheduleDate!)
                              : '변경 희망일 선택',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (_selectedReason == '기타') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _otherReasonController,
                  decoration: const InputDecoration(
                    hintText: '사유를 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _detailController,
                decoration: const InputDecoration(
                  labelText: '상세 사유 (선택)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('돌아가기'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.urgentRed,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        _selectedReason == '일정 변경'
                            ? '변경 요청'
                            : '다음',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
