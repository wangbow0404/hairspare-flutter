import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../view_models/portfolio_view_model.dart';

/// 갤러리 / 카메라 선택 후 [PortfolioViewModel.pickAndAdd] 호출.
Future<void> showPortfolioImageSourceSheet(BuildContext context) async {
  final vm = context.read<PortfolioViewModel>();
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppTheme.backgroundWhite,
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: IconMapper.icon(
                    'image',
                    size: 24,
                    color: AppTheme.textPrimary,
                  ) ??
                  const Icon(Icons.photo_library_outlined),
              title: const Text('갤러리에서 선택 (여러 장 가능)'),
              onTap: () {
                Navigator.pop(ctx);
                unawaited(vm.pickMultipleAndAdd());
              },
            ),
            ListTile(
              leading: IconMapper.icon(
                    'camera',
                    size: 24,
                    color: AppTheme.textPrimary,
                  ) ??
                  const Icon(Icons.photo_camera_outlined),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(ctx);
                unawaited(vm.pickAndAdd(ImageSource.camera));
              },
            ),
          ],
        ),
      );
    },
  );
}
