import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';

Future<void> showChallengeMoreOptionsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.grey[900],
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Container(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: IconMapper.icon('flag', size: 24, color: Colors.white) ??
                const Icon(Icons.flag_outlined, color: Colors.white),
            title: const Text('신고하기', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('신고 기능은 준비 중입니다'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          ListTile(
            leading: IconMapper.icon('bookmark', size: 24, color: Colors.white) ??
                const Icon(Icons.bookmark_border, color: Colors.white),
            title: const Text('저장하기', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('저장 기능은 준비 중입니다'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          ListTile(
            leading: IconMapper.icon('userx', size: 24, color: Colors.white) ??
                const Icon(Icons.person_remove_outlined, color: Colors.white),
            title: const Text('이 크리에이터 숨기기', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('숨기기 기능은 준비 중입니다'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(height: AppTheme.spacing2),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    ),
  );
}
