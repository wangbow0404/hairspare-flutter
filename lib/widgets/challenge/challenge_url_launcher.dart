import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchChallengeExternalUrl(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('링크를 열 수 없습니다: $url'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
