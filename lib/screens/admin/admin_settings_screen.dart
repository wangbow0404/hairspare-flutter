import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../config/business_config.dart';
import '../../core/di/service_locator.dart';
import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/business_setting_help.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_business_setting_field.dart';
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// M15. 비즈니스 설정 화면 (Stitch 그룹 탭 + 일괄 저장)
class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final AdminService _adminService = AdminService();

  List<Map<String, dynamic>> _groups = [];
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasLoadError = false;
  int _selectedGroupIndex = 0;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _originalValues = {};
  final Map<String, String> _settingLabels = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _hasLoadError = false;
    });

    try {
      final result = await _adminService.getBusinessSettings();
      final groups = (result['groups'] as List?)
              ?.map((g) => Map<String, dynamic>.from(g as Map))
              .toList() ??
          [];

      for (final controller in _controllers.values) {
        controller.dispose();
      }
      _controllers.clear();
      _originalValues.clear();
      _settingLabels.clear();

      for (final group in groups) {
        final settings = group['settings'] as List? ?? [];
        for (final setting in settings) {
          final map = Map<String, dynamic>.from(setting as Map);
          final key = map['key']?.toString() ?? '';
          if (key.isEmpty) continue;
          _controllers[key] = TextEditingController(
            text: map['value']?.toString() ?? '',
          );
          _originalValues[key] = map['value'];
          _settingLabels[key] = map['label']?.toString() ?? key;
        }
      }

      if (mounted) {
        setState(() {
          _groups = groups;
          _selectedGroupIndex = 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '설정 조회 실패: ${ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))}',
            ),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
        setState(() {
          _isLoading = false;
          _hasLoadError = true;
        });
      }
    }
  }

  List<String> _changedKeys() {
    final changed = <String>[];
    for (final entry in _controllers.entries) {
      final parsed = int.tryParse(entry.value.text.trim());
      if (parsed == null) continue;
      if (parsed != _originalValues[entry.key]) {
        changed.add(entry.key);
      }
    }
    return changed;
  }

  void _resetToDefaults() {
    for (final entry in _controllers.entries) {
      entry.value.text = _originalValues[entry.key]?.toString() ?? '';
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('저장된 값으로 되돌렸습니다')),
    );
  }

  Future<void> _saveAllChanges() async {
    final changed = _changedKeys();
    if (changed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('변경된 항목이 없습니다')),
      );
      return;
    }

    final invalid = changed.where((key) {
      return int.tryParse(_controllers[key]!.text.trim()) == null;
    }).toList();

    if (invalid.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 항목에 올바른 숫자를 입력해주세요'),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
      return;
    }

    final confirmed = await AdminActionDialog.confirm(
      context,
      title: '설정 저장',
      message: '${changed.length}개 항목을 저장합니다. 감사 로그에 기록됩니다.',
      confirmLabel: '저장',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);

    try {
      for (final key in changed) {
        final value = int.parse(_controllers[key]!.text.trim());
        await _adminService.updateBusinessSetting(key, value);
        _originalValues[key] = value;
      }
      await BusinessConfig.reload(sl<Dio>());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${changed.length}개 설정이 저장되었습니다')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  bool _isMoneyField(String key) {
    return key.contains('Fee') ||
        key.contains('Cost') ||
        key.contains('Deposit') ||
        key.contains('Price');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasLoadError) {
      return Center(
        child: FilledButton.icon(
          onPressed: _loadSettings,
          icon: const Icon(Icons.refresh),
          label: const Text('다시 시도'),
        ),
      );
    }

    final groupTabs = _groups.map((g) => g['title']?.toString() ?? '').toList();
    final selectedGroup = _groups.isNotEmpty ? _groups[_selectedGroupIndex] : null;
    final settings = (selectedGroup?['settings'] as List?) ?? [];
    final groupId = selectedGroup?['id']?.toString() ?? '';

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    AdminStitchTheme.pageMargin,
                    AdminStitchTheme.sectionGap,
                    AdminStitchTheme.pageMargin,
                    AdminStitchTheme.sectionGap,
                  ),
                  decoration: const BoxDecoration(
                    color: AdminStitchTheme.surfaceCard,
                    border: Border(
                      bottom: BorderSide(color: AdminStitchTheme.borderDefault),
                    ),
                  ),
                  child: const AdminStitchPageHeader(
                    title: '비즈니스 설정',
                    subtitle: '가격·한도·하이패스·제재 정책을 관리합니다.',
                  ),
                ),
              ),
              if (groupTabs.isNotEmpty)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _UnderlineTabHeader(
                    child: AdminStitchUnderlineTabBar(
                      tabs: groupTabs,
                      selectedIndex: _selectedGroupIndex,
                      onSelected: (index) =>
                          setState(() => _selectedGroupIndex = index),
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AdminStitchTheme.pageMargin,
                  AdminStitchTheme.sectionGap,
                  AdminStitchTheme.pageMargin,
                  AdminStitchTheme.sectionGap,
                ),
                sliver: SliverToBoxAdapter(
                  child: selectedGroup == null
                      ? const SizedBox.shrink()
                      : Container(
                          padding: const EdgeInsets.all(
                            AdminStitchTheme.componentPadding,
                          ),
                          decoration: AdminStitchTheme.cardDecoration.copyWith(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                BusinessSettingHelp.sectionTitleFor(
                                  groupId,
                                  selectedGroup['title']?.toString() ?? '',
                                ),
                                style: AdminStitchTheme.sectionHeader,
                              ),
                              if (selectedGroup['description'] != null) ...[
                                const SizedBox(height: AdminStitchTheme.stackTight),
                                Text(
                                  selectedGroup['description'].toString(),
                                  style: AdminStitchTheme.bodyMd.copyWith(
                                    color: AdminStitchTheme.textSecondary,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              for (var i = 0; i < settings.length; i++) ...[
                                if (i > 0)
                                  const SizedBox(height: AdminStitchTheme.sectionGap),
                                _buildSettingField(settings[i] as Map),
                              ],
                            ],
                          ),
                        ),
                ),
              ),
              SliverPadding(
                padding: AdminStitchListScreenShell.listPadding(context, extraBottom: 0),
                sliver: const SliverToBoxAdapter(child: SizedBox(height: 8)),
              ),
            ],
          ),
        ),
        AdminStitchBottomActionBar(
          isSaving: _isSaving,
          onReset: _resetToDefaults,
          onSave: _saveAllChanges,
          resetLabel: '초기화',
          saveLabel: '저장하기',
          saveButtonColor: AdminStitchTheme.primaryContainer,
          infoMessage: '저장 시 감사 로그에 기록되며 서버에 즉시 반영됩니다.',
        ),
      ],
    );
  }

  Widget _buildSettingField(Map setting) {
    final key = setting['key']?.toString() ?? '';
    final label = setting['label']?.toString() ?? key;
    final controller = _controllers[key];
    if (controller == null) return const SizedBox.shrink();

    return AdminBusinessSettingField(
      settingKey: key,
      label: label,
      controller: controller,
      isMoney: _isMoneyField(key),
    );
  }
}

class _UnderlineTabHeader extends SliverPersistentHeaderDelegate {
  _UnderlineTabHeader({required this.child});

  final Widget child;

  @override
  double get minExtent => 52;

  @override
  double get maxExtent => 52;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _UnderlineTabHeader oldDelegate) =>
      oldDelegate.child != child;
}
