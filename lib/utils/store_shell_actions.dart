import 'package:flutter/foundation.dart';

/// 스토어 셸(하단 바) → [StoreScreen] 액션 브릿지.
abstract final class StoreShellActions {
  static final ValueNotifier<int> openCategorySheet = ValueNotifier(0);

  static void requestCategorySheet() {
    openCategorySheet.value++;
  }
}
