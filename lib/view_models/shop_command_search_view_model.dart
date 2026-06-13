import 'package:flutter/material.dart';

import '../models/shop_command_search_item.dart';
import '../utils/shop_command_search_catalog.dart';

/// 샵 기능 키워드 검색 상태.
class ShopCommandSearchViewModel extends ChangeNotifier {
  final TextEditingController queryController = TextEditingController();

  ShopCommandSearchViewModel() {
    queryController.addListener(_onQueryChanged);
  }

  List<ShopCommandSearchItem> _results = const [];

  List<ShopCommandSearchItem> get results => _results;

  bool get hasQuery => queryController.text.trim().isNotEmpty;

  void _onQueryChanged() {
    final next = ShopCommandSearchCatalog.match(queryController.text);
    if (_listEquals(_results, next)) return;
    _results = next;
    notifyListeners();
  }

  void applyExampleKeyword(String keyword) {
    queryController.text = keyword;
    queryController.selection = TextSelection.collapsed(offset: keyword.length);
  }

  bool _listEquals(
    List<ShopCommandSearchItem> a,
    List<ShopCommandSearchItem> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].title != b[i].title) return false;
    }
    return true;
  }

  @override
  void dispose() {
    queryController.removeListener(_onQueryChanged);
    queryController.dispose();
    super.dispose();
  }
}
