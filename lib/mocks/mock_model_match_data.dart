import '../models/hair_model.dart';
import '../models/model_discovery_item.dart';
import '../models/model_match_preference.dart';

/// 모델 매칭 mock — 후보 목록·조건 필터링·하루 3회 매칭 카운트.
abstract final class MockModelMatchData {
  static String _mockImage(String key) => 'mock://model/$key';

  static const int dailyMatchLimit = 3;

  static String _ymd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String? _lastMatchYmd;
  static int _todayMatchCount = 0;

  static void _rolloverIfNeeded() {
    final today = _ymd(DateTime.now());
    if (_lastMatchYmd != today) {
      _lastMatchYmd = today;
      _todayMatchCount = 0;
    }
  }

  static int remainingMatchesToday() {
    _rolloverIfNeeded();
    final remaining = dailyMatchLimit - _todayMatchCount;
    return remaining < 0 ? 0 : remaining;
  }

  /// 매칭 1회 소모. 남은 횟수가 없으면 false.
  static bool consumeMatch() {
    _rolloverIfNeeded();
    if (_todayMatchCount >= dailyMatchLimit) return false;
    _todayMatchCount += 1;
    return true;
  }

  static final List<HairModel> _models = [
    HairModel(
      id: 'model-1',
      name: '이지아',
      age: 24,
      region: '강남구',
      imageUrls: const [
        'https://picsum.photos/seed/model-pop-1/400/600',
      ],
      gender: '여자',
      hairLength: '롱',
      preferredTreatments: ['레이어드컷', '전체염색'],
      imageTags: ['청순한', '우아한'],
      career: '경력(1년 이상)',
      shootAgreement: '얼굴 공개 필수',
      distanceKm: 3,
      intro: '자연스러운 컬러 변화를 좋아해요.',
    ),
    HairModel(
      id: 'model-2',
      name: '박서윤',
      age: 22,
      region: '마포구',
      imageUrls: const [
        'https://picsum.photos/seed/model-pop-2/400/600',
      ],
      gender: '여자',
      hairLength: '단발',
      preferredTreatments: ['커트', '디자인 컬러'],
      imageTags: ['힙한', '개성있는'],
      career: '신입',
      shootAgreement: '부분 공개 가능',
      distanceKm: 7,
      intro: '과감한 스타일 도전 환영!',
    ),
    HairModel(
      id: 'model-3',
      name: '최도현',
      age: 27,
      region: '용산구',
      imageUrls: const [
        'https://picsum.photos/seed/model-pop-3/400/600',
      ],
      gender: '남자',
      hairLength: '숏',
      preferredTreatments: ['커트', '볼륨매직'],
      imageTags: ['시크한', '스포티한'],
      career: '전문 모델',
      shootAgreement: '얼굴 공개 필수',
      distanceKm: 12,
      intro: '깔끔한 남성 스타일 위주로 활동합니다.',
    ),
    HairModel(
      id: 'model-4',
      name: '한예린',
      age: 26,
      region: '서초구',
      imageUrls: const [
        'https://picsum.photos/seed/model-pop-4/400/600',
      ],
      gender: '여자',
      hairLength: '중단발',
      preferredTreatments: ['히피펌', '전체염색'],
      imageTags: ['우아한', '단정한'],
      career: '경력(1년 이상)',
      shootAgreement: '부분 공개 가능',
      distanceKm: 18,
      intro: '웨이브 펌 모델 경험 많아요.',
    ),
    HairModel(
      id: 'model-5',
      name: '정민서',
      age: 23,
      region: '성동구',
      imageUrls: [
        _mockImage('model-5'),
      ],
      gender: '여자',
      hairLength: '베리롱',
      preferredTreatments: ['탈색', '디자인 컬러'],
      imageTags: ['힙한', '시크한'],
      career: '신입',
      shootAgreement: '비공개(헤어만)',
      distanceKm: 25,
      intro: '밝은 톤 탈색 작업 좋아합니다.',
    ),
    HairModel(
      id: 'model-6',
      name: '김하늘',
      age: 21,
      region: '동작구',
      imageUrls: [
        _mockImage('model-6'),
      ],
      gender: '여자',
      hairLength: '롱',
      preferredTreatments: ['레이어드컷', '볼륨매직'],
      imageTags: ['청순한', '단정한'],
      career: '전문 모델',
      shootAgreement: '얼굴 공개 필수',
      distanceKm: 9,
      intro: '결이 좋은 긴 머리 유지 중이에요.',
    ),
    HairModel(
      id: 'model-7',
      name: '오세진',
      age: 29,
      region: '광진구',
      imageUrls: [
        _mockImage('model-7'),
      ],
      gender: '남자',
      hairLength: '단발',
      preferredTreatments: ['디자인 컬러', '히피펌'],
      imageTags: ['개성있는', '힙한'],
      career: '경력(1년 이상)',
      shootAgreement: '부분 공개 가능',
      distanceKm: 33,
      intro: '실험적인 컬러 작업 환영합니다.',
    ),
    HairModel(
      id: 'model-8',
      name: '윤채아',
      age: 25,
      region: '송파구',
      imageUrls: [
        _mockImage('model-8'),
      ],
      gender: '여자',
      hairLength: '중단발',
      preferredTreatments: ['커트', '전체염색'],
      imageTags: ['단정한', '우아한'],
      career: '신입',
      shootAgreement: '얼굴 공개 필수',
      distanceKm: 15,
      intro: '내추럴한 데일리 스타일 선호해요.',
    ),
  ];

  /// 조건에 맞는 후보 필터링. 거리 정렬 후 반환.
  static List<HairModel> getCandidates(ModelMatchPreference pref) {
    final filtered = _models.where((m) {
      if (m.distanceKm > pref.distanceKm) return false;
      if (!pref.isGenderAny && m.gender != pref.gender) return false;
      if (!pref.isCareerAny && m.career != pref.career) return false;
      if (pref.hairLengths.isNotEmpty &&
          !pref.hairLengths.contains(m.hairLength)) {
        return false;
      }
      if (pref.treatments.isNotEmpty &&
          !pref.treatments.any(m.preferredTreatments.contains)) {
        return false;
      }
      if (pref.imageStyles.isNotEmpty &&
          !pref.imageStyles.any(m.imageTags.contains)) {
        return false;
      }
      if (m.shootAgreement != ModelMatchOptions.faceDisclosureRequired) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return filtered;
  }

  /// 추천 소진 시 노출 — 매칭 후보 풀과 분리된 인기·신규 모델.
  static final List<HairModel> _discoveryPopular = [
    HairModel(
      id: 'discovery-pop-1',
      name: '서하린',
      age: 23,
      region: '강남구',
      imageUrls: const [
        'https://picsum.photos/seed/discovery-pop-1/480/640',
      ],
      gender: '여자',
      hairLength: '롱',
      preferredTreatments: ['레이어드컷', '전체염색'],
      imageTags: ['청순한', '우아한'],
      career: '전문 모델',
      shootAgreement: '얼굴 공개 필수',
      distanceKm: 5,
      intro: '자연스러운 브라운 톤 작업을 자주 해요.',
    ),
    HairModel(
      id: 'discovery-pop-2',
      name: '강유나',
      age: 25,
      region: '마포구',
      imageUrls: const [
        'https://picsum.photos/seed/discovery-pop-2/480/640',
      ],
      gender: '여자',
      hairLength: '중단발',
      preferredTreatments: ['히피펌', '디자인 컬러'],
      imageTags: ['힙한', '개성있는'],
      career: '경력(1년 이상)',
      shootAgreement: '얼굴 공개 필수',
      distanceKm: 8,
      intro: '웨이브 펌·탈색 모델 경험이 많아요.',
    ),
    HairModel(
      id: 'discovery-pop-3',
      name: '임준혁',
      age: 28,
      region: '용산구',
      imageUrls: const [
        'https://picsum.photos/seed/discovery-pop-3/480/640',
      ],
      gender: '남자',
      hairLength: '숏',
      preferredTreatments: ['커트', '볼륨매직'],
      imageTags: ['시크한', '스포티한'],
      career: '전문 모델',
      shootAgreement: '얼굴 공개 필수',
      distanceKm: 11,
      intro: '남성 클린컷·투블럭 스타일 위주예요.',
    ),
  ];

  static final List<HairModel> _discoveryNew = [
    HairModel(
      id: 'discovery-new-1',
      name: '노다은',
      age: 20,
      region: '성동구',
      imageUrls: const [
        'https://picsum.photos/seed/discovery-new-1/480/640',
      ],
      gender: '여자',
      hairLength: '단발',
      preferredTreatments: ['커트', '전체염색'],
      imageTags: ['단정한', '청순한'],
      career: '신입',
      shootAgreement: '얼굴 공개 필수',
      distanceKm: 6,
      intro: '이번 주에 가입했어요. 첫 모델 활동 기대 중!',
    ),
    HairModel(
      id: 'discovery-new-2',
      name: '배시온',
      age: 22,
      region: '송파구',
      imageUrls: const [
        'https://picsum.photos/seed/discovery-new-2/480/640',
      ],
      gender: '남자',
      hairLength: '단발',
      preferredTreatments: ['디자인 컬러', '커트'],
      imageTags: ['힙한', '개성있는'],
      career: '신입',
      shootAgreement: '얼굴 공개 필수',
      distanceKm: 14,
      intro: '새로 올라온 모델이에요. 과감한 컬러 도전 환영!',
    ),
    HairModel(
      id: 'discovery-new-3',
      name: '황서아',
      age: 21,
      region: '동작구',
      imageUrls: const [
        'https://picsum.photos/seed/discovery-new-3/480/640',
      ],
      gender: '여자',
      hairLength: '베리롱',
      preferredTreatments: ['탈색', '레이어드컷'],
      imageTags: ['우아한', '시크한'],
      career: '신입',
      shootAgreement: '얼굴 공개 필수',
      distanceKm: 10,
      intro: '프로필을 막 등록했어요. 밝은 톤 작업 좋아해요.',
    ),
  ];

  /// 인기·신규를 섞어 반환. 이미 본 후보 ID는 제외.
  static List<ModelDiscoveryItem> getDiscoveryModels({
    Set<String> excludeIds = const {},
  }) {
    final popular = _discoveryPopular
        .where((m) => !excludeIds.contains(m.id))
        .map(
          (m) => ModelDiscoveryItem(
            model: m,
            kind: ModelDiscoveryKind.popular,
          ),
        );
    final newest = _discoveryNew
        .where((m) => !excludeIds.contains(m.id))
        .map(
          (m) => ModelDiscoveryItem(
            model: m,
            kind: ModelDiscoveryKind.newlyJoined,
          ),
        );

    final items = <ModelDiscoveryItem>[];
    final popList = popular.toList();
    final newList = newest.toList();
    final maxLen = popList.length > newList.length
        ? popList.length
        : newList.length;

    for (var i = 0; i < maxLen; i++) {
      if (i < popList.length) items.add(popList[i]);
      if (i < newList.length) items.add(newList[i]);
    }
    return items;
  }
}
