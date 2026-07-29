import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/models/store_product.dart';
import 'package:hairspare/widgets/store/store_category_row.dart';

void main() {
  testWidgets('카테고리를 탭하면 onSelected로 해당 카테고리를 전달한다', (tester) async {
    StoreProductCategory? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoreCategoryRow(
            selected: null,
            onSelected: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('가위'));
    await tester.pump();

    expect(selected, StoreProductCategory.scissors);
  });
}
