import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../theme/app_theme.dart';
import '../../view_models/shop_education_new_view_model.dart';
import '../../widgets/shop_education_new/shop_education_new_form_content.dart';

/// Shop/Designer 교육 올리기 화면. 상태는 [ShopEducationNewViewModel], UI는 `lib/widgets/shop_education_new/`.
class ShopEducationNewScreen extends StatefulWidget {
  const ShopEducationNewScreen({super.key});

  @override
  State<ShopEducationNewScreen> createState() => _ShopEducationNewScreenState();
}

class _ShopEducationNewScreenState extends State<ShopEducationNewScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    final vm = context.read<ShopEducationNewViewModel>();
    final ok = await vm.submit(_formKey);
    if (!mounted) return;
    if (ok) {
      await Future<void>.delayed(const Duration(milliseconds: 550));
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShopEducationNewViewModel(
        imagePicker: sl<ImagePicker>(),
      ),
      child: _ShopEducationNewScaffold(
        formKey: _formKey,
        onSubmit: _submit,
      ),
    );
  }
}

class _ShopEducationNewScaffold extends StatelessWidget {
  const _ShopEducationNewScaffold({
    required this.formKey,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopEducationNewViewModel>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3E8FF),
              Color(0xFFEFF6FF),
              Color(0xFFFDF2F8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  border: const Border(
                    bottom: BorderSide(color: AppTheme.primaryPurpleLight),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left,
                          color: AppTheme.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        '교육 등록',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
                            ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: ShopEducationNewFormContent(formKey: formKey),
              ),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  border: const Border(top: BorderSide(color: AppTheme.primaryPurpleLight)),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: vm.isLoading ? null : () => onSubmit(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        ),
                      ).copyWith(
                        backgroundColor: WidgetStateProperty.all(Colors.transparent),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF9333EA),
                              Color(0xFF7C3AED),
                              Color(0xFFEC4899),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: vm.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  '교육 등록하기',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
