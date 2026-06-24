import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/models/job.dart';
import 'package:hairspare/widgets/common/app_network_image.dart';
import 'package:hairspare/widgets/common/job_thumbnail.dart';

void main() {
  testWidgets('JobThumbnail uses AppNetworkImage for mock job URL', (tester) async {
    final job = Job.fromJson({
      'id': 'job-mock-1',
      'images': ['mock://job/job-mock-1'],
      'title': '테스트',
      'shopName': '샵',
      'date': '2026-06-01',
      'time': '10:00',
      'amount': 10000,
      'energy': 1,
      'requiredCount': 1,
      'regionId': 'seoul-gangnam',
      'status': 'published',
      'createdAt': DateTime.now().toIso8601String(),
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JobThumbnail(job: job, width: 200, height: 120),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(AppNetworkImage), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });
}
