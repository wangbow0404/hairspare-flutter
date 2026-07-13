import 'package:flutter/material.dart';

import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_stitch_list_cards.dart';
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// M17. 레퍼런스 데이터
class AdminReferenceScreen extends StatefulWidget {
  const AdminReferenceScreen({super.key});

  @override
  State<AdminReferenceScreen> createState() => _AdminReferenceScreenState();
}

class _AdminReferenceScreenState extends State<AdminReferenceScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic> _data = {};
  bool _isLoading = true;
  int _tabIndex = 0;

  static const _tabs = ['지역', '샵등급', '매칭태그', '카테고리'];
  static const _tabKeys = ['regions', 'tiers', 'matchTags', 'categories'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final r = await _adminService.getReferenceData();
    if (mounted) {
      setState(() {
        _data = r;
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _currentItems {
    final key = _tabKeys[_tabIndex];
    return (_data[key] as List?) ?? [];
  }

  void _showError(Object e) {
    if (!mounted) return;
    final appException = ErrorHandler.handleException(e);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ErrorHandler.getUserFriendlyMessage(appException)),
        backgroundColor: AppTheme.urgentRed,
      ),
    );
  }

  Future<void> _openForm({Map<String, dynamic>? existing}) async {
    final key = _tabKeys[_tabIndex];
    final regions = (_data['regions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _ReferenceFormDialog(
        tabKey: key,
        existing: existing,
        regions: regions,
      ),
    );
    if (result == null) return;

    try {
      if (existing == null) {
        switch (key) {
          case 'regions':
            await _adminService.createRegion(result);
            break;
          case 'tiers':
            await _adminService.createTier(result);
            break;
          case 'matchTags':
            await _adminService.createMatchTag(result);
            break;
          case 'categories':
            await _adminService.createCategory(result);
            break;
        }
      } else {
        final id = existing['id'] as String;
        switch (key) {
          case 'regions':
            await _adminService.updateRegion(id, result);
            break;
          case 'tiers':
            await _adminService.updateTier(id, result);
            break;
          case 'matchTags':
            await _adminService.updateMatchTag(id, result);
            break;
          case 'categories':
            await _adminService.updateCategory(id, result);
            break;
        }
      }
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(existing == null ? '추가되었습니다' : '수정되었습니다')),
        );
      }
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> item) async {
    final key = _tabKeys[_tabIndex];
    final confirmed = await AdminActionDialog.confirm(
      context,
      title: '삭제하시겠습니까?',
      message: _itemTitle(key, item),
      confirmLabel: '삭제',
      isDanger: true,
    );
    if (confirmed != true) return;

    final id = item['id'] as String;
    try {
      switch (key) {
        case 'regions':
          await _adminService.deleteRegion(id);
          break;
        case 'tiers':
          await _adminService.deleteTier(id);
          break;
        case 'matchTags':
          await _adminService.deleteMatchTag(id);
          break;
        case 'categories':
          await _adminService.deleteCategory(id);
          break;
      }
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('삭제되었습니다')));
      }
    } catch (e) {
      _showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminStitchListScreenShell(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminStitchPageHeader(
            title: '레퍼런스 데이터',
            subtitle: '지역·등급·태그·카테고리 CRUD',
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          Row(
            children: [
              Expanded(
                child: AdminStitchFilterChips(
                  tabs: _tabs,
                  selectedTab: _tabs[_tabIndex],
                  onTabChanged: (tab) {
                    setState(() => _tabIndex = _tabs.indexOf(tab));
                  },
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('추가'),
                style: FilledButton.styleFrom(
                  backgroundColor: AdminStitchTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AdminStitchListStateSliver.loading();
    }
    final items = _currentItems;
    if (items.isEmpty) {
      return AdminStitchListStateSliver.empty(
        emptyMessage: '${_tabs[_tabIndex]} 데이터가 없습니다',
      );
    }
    final key = _tabKeys[_tabIndex];
    return SliverPadding(
      padding: AdminStitchListScreenShell.listPadding(context),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AdminStitchTheme.sectionGap),
        itemBuilder: (_, i) {
          final item = items[i] as Map<String, dynamic>;
          return AdminStitchSimpleListCard(
            title: _itemTitle(key, item),
            subtitle: _itemSubtitle(key, item),
            icon: Icons.dataset_outlined,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _openForm(existing: item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.urgentRed),
                  onPressed: () => _confirmDelete(item),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _itemTitle(String key, Map<String, dynamic> item) {
    switch (key) {
      case 'regions':
        return [item['province'], item['city'], item['district']]
            .where((e) => e != null && e.toString().isNotEmpty)
            .join(' ');
      case 'tiers':
      case 'matchTags':
      case 'categories':
        return item['label']?.toString() ?? '';
      default:
        return item.toString();
    }
  }

  String _itemSubtitle(String key, Map<String, dynamic> item) {
    switch (key) {
      case 'tiers':
        return '공고 ${item['maxJobs']}개';
      case 'matchTags':
        return item['category']?.toString() ?? '';
      default:
        return item['id']?.toString() ?? '';
    }
  }
}

/// 지역/샵등급/매칭태그/카테고리 추가·수정 폼.
class _ReferenceFormDialog extends StatefulWidget {
  const _ReferenceFormDialog({
    required this.tabKey,
    required this.existing,
    required this.regions,
  });

  final String tabKey;
  final Map<String, dynamic>? existing;
  final List<Map<String, dynamic>> regions;

  @override
  State<_ReferenceFormDialog> createState() => _ReferenceFormDialogState();
}

class _ReferenceFormDialogState extends State<_ReferenceFormDialog> {
  static const _regionTypeLabels = {
    'province': '시/도',
    'city': '시/군구',
    'district': '동',
  };
  static const _matchTagCategoryLabels = {
    'gender': '성별',
    'hair_length': '헤어 길이',
    'treatment': '시술',
    'image_style': '이미지 스타일',
    'career': '경력',
  };

  late final TextEditingController _nameController;
  late final TextEditingController _minSchedController;
  late final TextEditingController _minThumbsController;
  late final TextEditingController _maxJobsController;
  late final TextEditingController _benefitsController;
  late final TextEditingController _subCategoriesController;

  late String _regionType;
  String? _parentId;
  late String _matchTagCategory;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(
      text: (e?['name'] ?? e?['label'])?.toString() ?? '',
    );
    _minSchedController =
        TextEditingController(text: (e?['minCompletedSchedules'] ?? 0).toString());
    _minThumbsController =
        TextEditingController(text: (e?['minThumbsUp'] ?? 0).toString());
    _maxJobsController = TextEditingController(text: (e?['maxJobs'] ?? 0).toString());
    _benefitsController = TextEditingController(
      text: ((e?['benefits'] as List?) ?? []).join('\n'),
    );
    _subCategoriesController = TextEditingController(
      text: ((e?['subCategories'] as List?) ?? []).join(', '),
    );
    _regionType = (e?['type'] as String?) ?? 'province';
    _parentId = e?['parentId'] as String?;
    _matchTagCategory = (e?['category'] as String?) ?? 'gender';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minSchedController.dispose();
    _minThumbsController.dispose();
    _maxJobsController.dispose();
    _benefitsController.dispose();
    _subCategoriesController.dispose();
    super.dispose();
  }

  String _title() {
    final isNew = widget.existing == null;
    switch (widget.tabKey) {
      case 'regions':
        return isNew ? '지역 추가' : '지역 수정';
      case 'tiers':
        return isNew ? '샵등급 추가' : '샵등급 수정';
      case 'matchTags':
        return isNew ? '매칭태그 추가' : '매칭태그 수정';
      case 'categories':
        return isNew ? '카테고리 추가' : '카테고리 수정';
      default:
        return isNew ? '추가' : '수정';
    }
  }

  void _save() {
    switch (widget.tabKey) {
      case 'regions':
        final name = _nameController.text.trim();
        if (name.isEmpty) return;
        Navigator.pop(context, {
          'name': name,
          'type': _regionType,
          'parentId': _parentId,
        });
        break;
      case 'tiers':
        final label = _nameController.text.trim();
        if (label.isEmpty) return;
        final benefits = _benefitsController.text
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        Navigator.pop(context, {
          'label': label,
          'minCompletedSchedules': int.tryParse(_minSchedController.text.trim()) ?? 0,
          'minThumbsUp': int.tryParse(_minThumbsController.text.trim()) ?? 0,
          'maxJobs': int.tryParse(_maxJobsController.text.trim()) ?? 0,
          'benefits': benefits,
        });
        break;
      case 'matchTags':
        final label = _nameController.text.trim();
        if (label.isEmpty) return;
        Navigator.pop(context, {
          'category': _matchTagCategory,
          'label': label,
        });
        break;
      case 'categories':
        final label = _nameController.text.trim();
        if (label.isEmpty) return;
        final subCategories = _subCategoriesController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        Navigator.pop(context, {
          'label': label,
          'subCategories': subCategories,
        });
        break;
    }
  }

  Widget _labeledField(String label, TextEditingController controller,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AdminStitchTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _choiceRow(String label, Map<String, String> options, String value,
      ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AdminStitchTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.entries.map((entry) {
              return ChoiceChip(
                label: Text(entry.value),
                selected: value == entry.key,
                onSelected: (_) => onChanged(entry.key),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _parentRegionDropdown() {
    final options = widget.regions
        .where((r) => r['id'] != widget.existing?['id'])
        .toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('상위 지역 (선택)',
              style: TextStyle(
                  color: AdminStitchTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String?>(
            initialValue: _parentId,
            isExpanded: true,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('없음')),
              ...options.map((r) => DropdownMenuItem<String?>(
                    value: r['id'] as String,
                    child: Text(
                      [r['province'], r['city'], r['district']]
                          .where((e) => e != null && e.toString().isNotEmpty)
                          .join(' '),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
            ],
            onChanged: (v) => setState(() => _parentId = v),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> fields;
    switch (widget.tabKey) {
      case 'regions':
        fields = [
          _labeledField('지역 이름', _nameController),
          _choiceRow('구분', _regionTypeLabels, _regionType,
              (v) => setState(() => _regionType = v)),
          _parentRegionDropdown(),
        ];
        break;
      case 'tiers':
        fields = [
          _labeledField('등급명', _nameController),
          _labeledField('완료 스케줄 기준', _minSchedController,
              keyboardType: TextInputType.number),
          _labeledField('응원 수 기준', _minThumbsController,
              keyboardType: TextInputType.number),
          _labeledField('최대 공고 등록 수', _maxJobsController,
              keyboardType: TextInputType.number),
          _labeledField('혜택 (줄바꿈으로 구분)', _benefitsController, maxLines: 4),
        ];
        break;
      case 'matchTags':
        fields = [
          _choiceRow('분류', _matchTagCategoryLabels, _matchTagCategory,
              (v) => setState(() => _matchTagCategory = v)),
          _labeledField('태그명', _nameController),
        ];
        break;
      case 'categories':
        fields = [
          _labeledField('카테고리명', _nameController),
          _labeledField('서브카테고리 (쉼표로 구분)', _subCategoriesController, maxLines: 2),
        ];
        break;
      default:
        fields = [];
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _title(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              ...fields,
              const SizedBox(height: 8),
              const Text(
                '변경 내역은 감사 로그에 기록됩니다.',
                style: TextStyle(color: AdminStitchTheme.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AdminStitchTheme.primary,
                    ),
                    child: const Text('저장'),
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
