import 'package:intl/intl.dart';

import '../../models/job.dart';
import '../../utils/region_helper.dart';
import '../../utils/work_schedule_utils.dart';

String jobDetailCountdownText(int? countdown) {
  if (countdown == null || countdown <= 0) return '마감됨';
  final hours = countdown ~/ 3600;
  final minutes = (countdown % 3600) ~/ 60;
  if (hours > 0) {
    return '$hours시간 $minutes분';
  }
  return '$minutes분';
}

String jobDetailDeadlineTime(int? countdown) {
  if (countdown == null) return '';
  final deadline = DateTime.now().add(Duration(seconds: countdown));
  final hours = deadline.hour.toString().padLeft(2, '0');
  final minutes = deadline.minute.toString().padLeft(2, '0');
  return '오늘 $hours:$minutes';
}

String jobDetailRegionName(String regionId) =>
    RegionHelper.getRegionName(regionId);

/// 연도 제외 (예: 2월 16일)
String jobDetailFormatJobDate(String date) {
  try {
    final d = DateTime.parse(date);
    return DateFormat('M월 d일', 'ko_KR').format(d);
  } catch (_) {
    return date;
  }
}

String jobDetailFormatJobTime(Job job) => WorkScheduleUtils.formatJobTimeRange(job);
