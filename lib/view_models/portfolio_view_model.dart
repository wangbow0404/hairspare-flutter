import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../core/di/service_locator.dart';
import '../core/services/global_messenger_service.dart';
import '../models/user.dart';
import '../services/portfolio_service.dart';
import '../utils/error_handler.dart';

/// 작업 포트폴리오 편집 — 갤러리·카메라 추가·삭제.
class PortfolioViewModel extends ChangeNotifier {
  PortfolioViewModel({
    required this.ownerId,
    required this.ownerRole,
    PortfolioService? portfolioService,
    ImagePicker? imagePicker,
  })  : _portfolioService = portfolioService ?? sl<PortfolioService>(),
        _imagePicker = imagePicker ?? sl<ImagePicker>();

  final String ownerId;
  final String ownerRole;
  final PortfolioService _portfolioService;
  final ImagePicker _imagePicker;

  GlobalMessengerService get _messenger => sl<GlobalMessengerService>();

  List<String> _images = [];
  List<String> get images => _images;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _error;
  String? get error => _error;

  String get ownerRoleLabel =>
      ownerRole == UserRole.shop.name ? '샵' : '스페어';

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _images = await _portfolioService.getImageUrls(
        ownerId: ownerId,
        ownerRole: ownerRole,
      );
    } catch (e) {
      _error = ErrorHandler.handleException(e).message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickAndAdd(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 88,
    );
    if (picked == null) return;
    await _addPickedFiles([picked]);
  }

  /// 갤러리에서 여러 장을 한 번에 선택해 순차 업로드한다.
  Future<void> pickMultipleAndAdd() async {
    final picked = await _imagePicker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 88,
    );
    if (picked.isEmpty) return;
    await _addPickedFiles(picked);
  }

  Future<void> _addPickedFiles(List<XFile> picked) async {
    final validPaths = <String>[];
    for (final p in picked) {
      final length = await File(p.path).length();
      if (length > 12 * 1024 * 1024) {
        _messenger.showError('${p.name} — 이미지는 12MB 이하여야 합니다.');
        continue;
      }
      validPaths.add(p.path);
    }
    if (validPaths.isEmpty) return;

    _isSaving = true;
    notifyListeners();
    var addedCount = 0;
    try {
      for (final path in validPaths) {
        _images = await _portfolioService.addLocalImage(
          ownerId: ownerId,
          ownerRole: ownerRole,
          localPath: path,
        );
        addedCount++;
        notifyListeners();
      }
      _messenger.showSuccess(
        addedCount > 1 ? '사진 $addedCount장이 추가되었습니다.' : '사진이 추가되었습니다.',
      );
    } catch (e) {
      _messenger.showError(ErrorHandler.handleException(e).message);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= _images.length) return;
    _isSaving = true;
    notifyListeners();
    try {
      _images = await _portfolioService.removeAt(
        ownerId: ownerId,
        ownerRole: ownerRole,
        index: index,
      );
      _messenger.showSuccess('사진을 삭제했습니다.');
    } catch (e) {
      _messenger.showError(ErrorHandler.handleException(e).message);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
