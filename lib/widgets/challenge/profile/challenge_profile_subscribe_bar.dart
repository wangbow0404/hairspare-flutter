import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hairspare/providers/auth_provider.dart';
import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/view_models/challenge_profile_view_model.dart';

/// 구독 CTA — **화면에서 이 위젯만 옮기면** 버튼 위치를 바꿀 수 있습니다.
class ChallengeProfileSubscribeBar extends StatelessWidget {
  const ChallengeProfileSubscribeBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ChallengeProfileViewModel, _SubscribeUiState>(
      selector: (_, vm) => _SubscribeUiState(
        show: vm.showSubscribeButton,
        isSubscribed: vm.profile?.isSubscribed ?? false,
        isLoading: vm.isSubscribeLoading,
      ),
      builder: (context, state, _) {
        if (!state.show) return const SizedBox.shrink();

        final vm = context.read<ChallengeProfileViewModel>();
        final auth = context.read<AuthProvider>();

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacing4,
            0,
            AppTheme.spacing4,
            AppTheme.spacing3,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: state.isSubscribed
                ? OutlinedButton(
                    onPressed: state.isLoading
                        ? null
                        : () => vm.toggleSubscribe(auth.currentUser),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.borderGray),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            AppTheme.borderRadius(AppTheme.radiusLg),
                      ),
                    ),
                    child: _SubscribeLabel(
                      text: '구독 중',
                      loading: state.isLoading,
                    ),
                  )
                : FilledButton(
                    onPressed: state.isLoading
                        ? null
                        : () => vm.toggleSubscribe(auth.currentUser),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            AppTheme.borderRadius(AppTheme.radiusLg),
                      ),
                    ),
                    child: _SubscribeLabel(
                      text: '구독하기',
                      loading: state.isLoading,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _SubscribeUiState {
  const _SubscribeUiState({
    required this.show,
    required this.isSubscribed,
    required this.isLoading,
  });

  final bool show;
  final bool isSubscribed;
  final bool isLoading;

  @override
  bool operator ==(Object other) =>
      other is _SubscribeUiState &&
      show == other.show &&
      isSubscribed == other.isSubscribed &&
      isLoading == other.isLoading;

  @override
  int get hashCode => Object.hash(show, isSubscribed, isLoading);
}

class _SubscribeLabel extends StatelessWidget {
  const _SubscribeLabel({
    required this.text,
    required this.loading,
  });

  final String text;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    }
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
