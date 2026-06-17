import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/stitch/stitch_energy_hero_card.dart';
import '../../widgets/stitch/stitch_empty_state.dart';
import '../../services/energy_service.dart';
import 'energy_purchase_screen.dart';

/// Next.js와 동일한 에너지 화면
class EnergyScreen extends StatefulWidget {
  const EnergyScreen({super.key});

  @override
  State<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen> {
  int _balance = 0;
  List<EnergyTransaction> _transactions = [];
  bool _isLoading = true;
  final EnergyService _energyService = EnergyService();

  @override
  void initState() {
    super.initState();
    _loadEnergyData();
  }

  Future<void> _loadEnergyData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final walletData = await _energyService.getWallet();
      setState(() {
        _balance = walletData['balance'] ?? 0;
        _transactions = walletData['transactions'] ?? [];
        _isLoading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final errorMessage = error.toString().contains('connection errored') ||
                error.toString().contains('XMLHttpRequest')
            ? '서버에 연결할 수 없습니다. Next.js 서버가 실행 중인지 확인해주세요.'
            : '에너지 정보를 불러오는 중 오류가 발생했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.urgentRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy년 M월 d일 HH:mm', 'ko_KR').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        appBar: SpareSubpageAppBar(
          title: '내 에너지',
          showBackButton: canPop,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareSubpageAppBar(
        title: '내 에너지',
        showBackButton: canPop,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: AppTheme.spacing(AppTheme.spacing4),
              child: StitchEnergyHeroCard(
                balance: _balance,
                onPurchase: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EnergyPurchaseScreen(),
                    ),
                  ).then((_) => _loadEnergyData());
                },
              ),
            ),

            // Transactions
            Padding(
              padding: AppTheme.spacing(AppTheme.spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '거래 내역',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.stitchTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundWhite,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      border: Border.all(color: AppTheme.borderGray),
                      boxShadow: AppTheme.stitchSoftShadow,
                    ),
                    child: _transactions.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(AppTheme.spacing8),
                            child: StitchEmptyState(
                              message: '거래 내역이 없습니다',
                              iconName: 'zap',
                            ),
                          )
                        : Column(
                            children: _transactions.map((transaction) {
                              final isPositive = transaction.type == 'purchased' ||
                                  transaction.type == 'returned';
                              final color = isPositive
                                  ? AppTheme.primaryGreen
                                  : AppTheme.urgentRed;
                              final bgColor = isPositive
                                  ? AppTheme.green100
                                  : AppTheme.urgentRedLight;

                              return Container(
                                padding: AppTheme.spacing(AppTheme.spacing4),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppTheme.borderGray,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                      ),
                                      child: Icon(
                                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                                        size: 20,
                                        color: color,
                                      ),
                                    ),
                                    const SizedBox(width: AppTheme.spacing3),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            transaction.description.isNotEmpty
                                                ? transaction.description
                                                : (isPositive ? '충전' : '사용'),
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: AppTheme.spacing1 / 2),
                                          Text(
                                            _formatDate(transaction.timestamp),
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontSize: 12,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${isPositive ? '+' : '-'}${transaction.amount}개',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EnergyTransaction {
  final String id;
  final String type;
  final int amount;
  final String description;
  final String timestamp;

  EnergyTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
  });
}
