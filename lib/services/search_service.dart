import '../models/job.dart';
import '../models/space_rental.dart';
import '../screens/spare/education_screen.dart';
import '../screens/spare/challenge_screen.dart';
import '../utils/api_config.dart';
import 'job_service.dart';
import 'space_rental_service.dart';
import '../mocks/mock_spare_data.dart';

/// 통합 검색 서비스
class SearchService {
  final JobService _jobService = JobService();
  final SpaceRentalService _spaceRentalService = SpaceRentalService();

  Future<List<Job>> searchJobs(String query) async {
    return _jobService.getJobs(searchQuery: query.trim().isEmpty ? null : query);
  }

  Future<List<SpaceRental>> searchSpaces(String query) async {
    final spaces = await _spaceRentalService.getSpaceRentals();
    if (query.trim().isEmpty) return spaces;
    final q = query.trim().toLowerCase();
    return spaces
        .where((s) =>
            s.shopName.toLowerCase().contains(q) ||
            s.address.toLowerCase().contains(q))
        .toList();
  }

  Future<List<Education>> searchEducations(String query) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.getEducationsForSearch(query);
    }
    return [];
  }

  Future<List<Challenge>> searchChallenges(String query) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.getChallengesForSearch(query);
    }
    return [];
  }
}
