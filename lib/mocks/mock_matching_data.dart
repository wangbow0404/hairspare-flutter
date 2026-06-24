import '../models/hair_model.dart';
import '../models/match_like.dart';
import '../models/match_profile.dart';
import '../models/model_home_data.dart';
import 'mock_model_messaging_data.dart';

/// 상호 좋아요 매칭 mock — 단일 소스.
abstract final class MockMatchingData {
  MockMatchingData._();

  static const modelId = 'mock-model-dev';
  static const modelName = '모델테스트';

  static bool _seeded = false;
  static final List<MatchLike> _likes = [];

  static String _mockImg(String key) => 'mock://portfolio/$key';

  static MatchProfile get modelProfile => MatchProfile(
        id: modelId,
        role: 'model',
        displayName: modelName,
        subtitle: '강남구 · 롱 레이어드',
        intro: '세련된 롱 레이어드 컷 모델 가능합니다.',
        tags: const ['롱 레이어드', '전체염색', '청순한'],
        portfolioImages: [
          _mockImg('model-portfolio-1'),
          _mockImg('model-portfolio-2'),
        ],
        region: '강남구',
      );

  static MatchProfile _spareProfile({
    required String id,
    required String name,
    required String treatment,
    required String region,
    required String intro,
    required List<String> portfolio,
    List<String> tags = const [],
  }) =>
      MatchProfile(
        id: id,
        role: 'spare',
        displayName: name,
        subtitle: '$treatment · $region',
        treatment: treatment,
        region: region,
        intro: intro,
        tags: tags,
        portfolioImages: portfolio,
        avatarUrl: portfolio.isNotEmpty ? portfolio.first : null,
      );

  static void _ensureSeeded() {
    if (_seeded) return;
    _seeded = true;
    final now = DateTime.now();

    _likes.addAll([
      MatchLike(
        id: 'like-pending-1',
        fromProfile: _spareProfile(
          id: 'spare-designer-1',
          name: '김수민 디자이너',
          treatment: '전체염색',
          region: '강남구',
          intro: '내추럴 염색·탈색 전문. 모델 촬영 경험 풍부합니다.',
          portfolio: [
            _mockImg('spare-kim-1'),
            _mockImg('spare-kim-2'),
            _mockImg('spare-kim-3'),
          ],
          tags: ['전체염색', '탈색', '5년 경력'],
        ),
        toProfile: modelProfile,
        status: MatchLikeStatus.pending,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      MatchLike(
        id: 'like-pending-2',
        fromProfile: _spareProfile(
          id: 'spare-designer-2',
          name: '박준호 디자이너',
          treatment: '레이어드 컷',
          region: '서초구',
          intro: '레이어드·히피펌 스타일링을 좋아합니다.',
          portfolio: [
            _mockImg('spare-park-1'),
            _mockImg('spare-park-2'),
          ],
          tags: ['레이어드', '컷', '3년 경력'],
        ),
        toProfile: modelProfile,
        status: MatchLikeStatus.pending,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      MatchLike(
        id: 'like-pending-3',
        fromProfile: _spareProfile(
          id: 'spare-designer-3',
          name: '이하늘 디자이너',
          treatment: '펌 모델',
          region: '송파구',
          intro: '펌·볼륨매직 모델 모집 중입니다.',
          portfolio: [
            _mockImg('spare-lee-1'),
            _mockImg('spare-lee-2'),
          ],
          tags: ['펌', '볼륨매직'],
        ),
        toProfile: modelProfile,
        status: MatchLikeStatus.pending,
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      MatchLike(
        id: 'like-matched-1',
        fromProfile: _spareProfile(
          id: 'spare-designer-4',
          name: '빌라드블랑 강남점',
          treatment: '전체염색',
          region: '강남구',
          intro: '프리미엄 살롱에서 모델 협업 진행 중입니다.',
          portfolio: [
            _mockImg('spare-villa-1'),
            _mockImg('spare-villa-2'),
          ],
          tags: ['전체염색', '프리미엄'],
        ),
        toProfile: modelProfile,
        status: MatchLikeStatus.matched,
        createdAt: now.subtract(const Duration(days: 2)),
        chatId: 'model-chat-1',
      ),
      MatchLike(
        id: 'like-matched-2',
        fromProfile: _spareProfile(
          id: 'spare-designer-5',
          name: '헤어스튜디오 A',
          treatment: '레이어드 컷',
          region: '서초구',
          intro: '트렌디한 레이어드 스타일 전문.',
          portfolio: [
            _mockImg('spare-studio-1'),
          ],
          tags: ['레이어드', '컷'],
        ),
        toProfile: modelProfile,
        status: MatchLikeStatus.matched,
        createdAt: now.subtract(const Duration(days: 1)),
        chatId: 'model-chat-2',
      ),
    ]);
  }

  static List<MatchLike> getReceivedLikes({required String modelUserId}) {
    _ensureSeeded();
    return _likes
        .where(
          (l) =>
              l.toProfile.id == modelUserId &&
              l.status == MatchLikeStatus.pending,
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<MatchLike> getMatches({required String modelUserId}) {
    _ensureSeeded();
    return _likes
        .where(
          (l) =>
              l.toProfile.id == modelUserId &&
              l.status == MatchLikeStatus.matched,
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static MatchLike? getLikeById(String likeId) {
    _ensureSeeded();
    for (final like in _likes) {
      if (like.id == likeId) return like;
    }
    return null;
  }

  static bool hasPendingLike({
    required String fromId,
    required String toId,
  }) {
    _ensureSeeded();
    return _likes.any(
      (l) =>
          l.fromProfile.id == fromId &&
          l.toProfile.id == toId &&
          l.status == MatchLikeStatus.pending,
    );
  }

  static MatchProfile profileFromHairModel(HairModel model) => MatchProfile(
        id: model.id,
        role: 'model',
        displayName: model.name,
        subtitle: '${model.region} · ${model.hairLength}',
        intro: model.intro,
        tags: [
          model.hairLength,
          ...model.preferredTreatments.take(2),
          ...model.imageTags.take(1),
        ],
        portfolioImages: model.imageUrls,
        region: model.region,
        treatment: model.preferredTreatments.isNotEmpty
            ? model.preferredTreatments.first
            : null,
      );

  /// 스페어/디자이너 → 모델 하트 전송 (pending).
  static Future<MatchLike> registerSentLike({
    required MatchProfile fromProfile,
    required MatchProfile toProfile,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _ensureSeeded();

    if (hasPendingLike(fromId: fromProfile.id, toId: toProfile.id)) {
      return _likes.firstWhere(
        (l) =>
            l.fromProfile.id == fromProfile.id &&
            l.toProfile.id == toProfile.id &&
            l.status == MatchLikeStatus.pending,
      );
    }

    final like = MatchLike(
      id: 'like-${DateTime.now().millisecondsSinceEpoch}',
      fromProfile: fromProfile,
      toProfile: toProfile,
      status: MatchLikeStatus.pending,
      createdAt: DateTime.now(),
    );
    _likes.insert(0, like);
    return like;
  }

  /// 모델이 받은 하트 수락 → 매칭 + 채팅 생성.
  static Future<String> acceptLike(String likeId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _ensureSeeded();
    final index = _likes.indexWhere((l) => l.id == likeId);
    if (index < 0) {
      throw StateError('Like not found: $likeId');
    }
    final like = _likes[index];
    if (like.status != MatchLikeStatus.pending) {
      throw StateError('Like is not pending: $likeId');
    }

    final chatId = await MockModelMessagingData.createChatForMatch(
      spareId: like.fromProfile.id,
      spareName: like.fromProfile.displayName,
      modelId: like.toProfile.id,
      modelName: like.toProfile.displayName,
      jobTitle: like.fromProfile.treatment ?? '모델 매칭',
    );

    _likes[index] = like.copyWith(
      status: MatchLikeStatus.matched,
      chatId: chatId,
    );
    return chatId;
  }

  static Future<void> declineLike(String likeId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _ensureSeeded();
    _likes.removeWhere((l) => l.id == likeId && l.status == MatchLikeStatus.pending);
  }

  static Future<void> cancelMatchByChatId(String chatId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _ensureSeeded();
    _likes.removeWhere(
      (l) => l.chatId == chatId && l.status == MatchLikeStatus.matched,
    );
    await MockModelMessagingData.deleteChat(chatId);
  }

  static bool isModelDesignerChatId(String chatId) =>
      MockModelMessagingData.isModelChatId(chatId);

  static List<ModelHomeInterest> pendingHomeInterests() {
    return getReceivedLikes(modelUserId: modelId)
        .map(
          (like) => ModelHomeInterest(
            id: like.id,
            designerName: like.fromProfile.displayName,
            treatment: like.fromProfile.treatment ?? '',
            region: like.fromProfile.region ?? '',
            avatarUrl: like.fromProfile.avatarUrl,
            isPrimaryCta: true,
          ),
        )
        .toList();
  }

  static int pendingCountForModel() =>
      getReceivedLikes(modelUserId: modelId).length;
}
