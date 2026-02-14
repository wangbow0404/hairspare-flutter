import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/spare_app_bar.dart';
import '../../providers/point_provider.dart';
import '../../models/point_transaction.dart';

/// 포인트 내역 화면 (적립/사용)
class PointHistoryScreen extends StatefulWidget {
  const PointHistoryScreen({super.key});

  @override
  State<PointHistoryScreen> createState() => _PointHistoryScreenState();
}

class _PointHistoryScreenState extends State<PointHistoryScreen> {
  String _filter = 'all'; // 'all' | 'earn' | 'spend'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PointProvider>()
        ..loadBalance()
        ..loadHistory(type: _filter == 'all' ? null : _filter);
    });
  }

  void _onFilterChanged(String value) {
    setState(() {
      _filter = value;
      context.read<PointProvider>().loadHistory(
            type: value == 'all' ? null : value,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareAppBar(showBackButton: true),
      body: Column(
        children: [
          Consumer<PointProvider>(
            builder: (context, provider, _) {
              return Container(
                width: double.infinity,
                margin: AppTheme.spacing(AppTheme.spacing4),
                padding: AppTheme.spacing(AppTheme.spacing4),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundWhite,
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
                  border: Border.all(color: AppTheme.borderGray),
                ),
                child: Column(
                  children: [
                    Text(
                      '보유 포인트',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    SizedBox(height: AppTheme.spacing2),
                    Text(
                      provider.isLoading
                          ? '-'
                          : NumberFormat('#,###').format(provider.balance),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryPurple,
                          ),
                    ),
                    Text(
                      'P',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: AppTheme.spacingSymmetric(horizontal: AppTheme.spacing4, vertical: 0),
            child: Row(
              children: [
                _FilterChip(
                  label: '전체',
                  isActive: _filter == 'all',
                  onTap: () => _onFilterChanged('all'),
                ),
                SizedBox(width: AppTheme.spacing2),
                _FilterChip(
                  label: '적립',
                  isActive: _filter == 'earn',
                  onTap: () => _onFilterChanged('earn'),
                ),
                SizedBox(width: AppTheme.spacing2),
                _FilterChip(
                  label: '사용',
                  isActive: _filter == 'spend',
                  onTap: () => _onFilterChanged('spend'),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.spacing4),
          Expanded(
            child: Consumer<PointProvider>(
              builder: (context, provider, _) {
                if (provider.isHistoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          provider.error!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppTheme.spacing4),
                        ElevatedButton(
                          onPressed: () => provider.loadHistory(type: _filter == 'all' ? null : _filter),
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  );
                }
                if (provider.history.isEmpty) {
                  return Center(
                    child: Text(
                      '포인트 내역이 없습니다',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => provider.loadHistory(type: _filter == 'all' ? null : _filter),
                  child: ListView.builder(
                    padding: AppTheme.spacing(AppTheme.spacing4),
                    itemCount: provider.history.length,
                    itemBuilder: (context, index) {
                      final tx = provider.history[index];
                      return _TransactionCard(transaction: tx);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppTheme.spacingSymmetric(
          horizontal: AppTheme.spacing3,
          vertical: AppTheme.spacing2,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryPurple : AppTheme.backgroundGray,
          borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppTheme.textSecondary,
              ),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final PointTransaction transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isEarn = transaction.type == 'earn';
    final amount = transaction.amount;
    final displayAmount = isEarn ? amount : -amount;

    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing3),
      padding: AppTheme.spacing(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isEarn
                  ? AppTheme.primaryGreen.withOpacity(0.15)
                  : AppTheme.urgentRed.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarn ? Icons.add : Icons.remove,
              color: isEarn ? AppTheme.primaryGreen : AppTheme.urgentRed,
              size: 24,
            ),
          ),
          SizedBox(width: AppTheme.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                ),
                SizedBox(height: AppTheme.spacing1),
                Text(
                  DateFormat('yyyy.M.d HH:mm', 'ko_KR').format(transaction.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '${isEarn ? '+' : ''}${NumberFormat('#,###').format(displayAmount)}P',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isEarn ? AppTheme.primaryGreen : AppTheme.urgentRed,
                ),
          ),
        ],
      ),
    );
  }
}
