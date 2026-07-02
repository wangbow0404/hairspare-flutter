import 'package:flutter/material.dart';

import '../../models/job.dart';
import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';

/// 본인인증 유도 모달.
class JobDetailVerificationModal extends StatelessWidget {
  const JobDetailVerificationModal({
    super.key,
    required this.onDismiss,
    required this.onGoVerify,
  });

  final VoidCallback onDismiss;
  final VoidCallback onGoVerify;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      child: GestureDetector(
        onTap: onDismiss,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: AppTheme.spacing(AppTheme.spacing4),
              constraints: const BoxConstraints(maxWidth: 384),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: AppTheme.borderRadius(AppTheme.radius2xl),
                boxShadow: AppTheme.shadowXl,
              ),
              padding: AppTheme.spacing(AppTheme.spacing6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon:
                          IconMapper.icon(
                            'x',
                            size: 20,
                            color: AppTheme.textSecondary,
                          ) ??
                          const Icon(
                            Icons.close,
                            color: AppTheme.textSecondary,
                          ),
                      onPressed: onDismiss,
                    ),
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                    ),
                    child:
                        IconMapper.icon(
                          'shield',
                          size: 32,
                          color: AppTheme.primaryGreen,
                        ) ??
                        const Icon(
                          Icons.shield,
                          size: 32,
                          color: AppTheme.primaryGreen,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    '본인인증',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  Text(
                    '휴대폰 본인인증을 진행해주세요',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing6),
                  Container(
                    padding: AppTheme.spacing(AppTheme.spacing4),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundGray,
                      borderRadius: AppTheme.borderRadius(AppTheme.radius2xl),
                    ),
                    child: Text(
                      '본인인증 진행 후에 지원이 가능합니다',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                        color: AppTheme.textGray700,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onGoVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: AppTheme.spacing(AppTheme.spacing4),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.borderRadius(
                            AppTheme.radiusXl,
                          ),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        '본인인증하러가기',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 지원 확인(에너지 잠금) 모달.
class JobDetailConfirmApplyModal extends StatelessWidget {
  const JobDetailConfirmApplyModal({
    super.key,
    required this.job,
    required this.onConfirm,
    required this.onCancel,
  });

  final Job job;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      child: GestureDetector(
        onTap: onCancel,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: AppTheme.spacing(AppTheme.spacing4),
              constraints: const BoxConstraints(maxWidth: 384),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: AppTheme.borderRadius(AppTheme.radius2xl),
                boxShadow: AppTheme.shadowXl,
              ),
              padding: AppTheme.spacing(AppTheme.spacing8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.stitchPrimaryContainer.withValues(alpha: 0.1),
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                    ),
                    child:
                        IconMapper.icon(
                          'zap',
                          size: 32,
                          color: AppTheme.stitchPrimaryContainer,
                        ) ??
                        const Icon(
                          Icons.bolt,
                          size: 32,
                          color: AppTheme.stitchPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    '지원 확인',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  Text(
                    '정말 지원하시겠습니까?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.stitchPrimaryContainer,
                        foregroundColor: Colors.white,
                        padding: AppTheme.spacing(AppTheme.spacing4),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.borderRadius(
                            AppTheme.radiusXl,
                          ),
                        ),
                      ),
                      child: Text(
                        '확인',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing3),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.backgroundGray,
                        foregroundColor: AppTheme.textGray700,
                        padding: AppTheme.spacing(AppTheme.spacing4),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.borderRadius(
                            AppTheme.radiusXl,
                          ),
                        ),
                      ),
                      child: Text(
                        '취소',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textGray700,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
