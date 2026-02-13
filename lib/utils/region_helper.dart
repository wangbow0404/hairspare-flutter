import '../models/region.dart';

/// 지역 이름을 가져오는 유틸리티 클래스
class RegionHelper {
  /// 지역 데이터 (Next.js의 regions.ts와 동일)
  static final List<Region> _regions = [
    // 시/도
    Region(id: 'seoul', name: '서울', type: RegionType.province),
    Region(id: 'busan', name: '부산', type: RegionType.province),
    Region(id: 'daegu', name: '대구', type: RegionType.province),
    Region(id: 'incheon', name: '인천', type: RegionType.province),
    Region(id: 'gwangju', name: '광주', type: RegionType.province),
    Region(id: 'daejeon', name: '대전', type: RegionType.province),
    Region(id: 'ulsan', name: '울산', type: RegionType.province),
    Region(id: 'gyeonggi', name: '경기', type: RegionType.province),
    Region(id: 'gangwon', name: '강원', type: RegionType.province),
    Region(id: 'chungbuk', name: '충북', type: RegionType.province),
    Region(id: 'chungnam', name: '충남', type: RegionType.province),
    Region(id: 'jeonbuk', name: '전북', type: RegionType.province),
    Region(id: 'jeonnam', name: '전남', type: RegionType.province),
    Region(id: 'gyeongbuk', name: '경북', type: RegionType.province),
    Region(id: 'gyeongnam', name: '경남', type: RegionType.province),
    Region(id: 'sejong', name: '세종', type: RegionType.province),
    Region(id: 'jeju', name: '제주', type: RegionType.province),
    
    // 서울 구
    Region(id: 'seoul-gangnam', name: '강남구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-gangdong', name: '강동구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-gangbuk', name: '강북구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-gangseo', name: '강서구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-gwanak', name: '관악구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-gwangjin', name: '광진구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-guro', name: '구로구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-nowon', name: '노원구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-dobong', name: '도봉구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-dongdaemun', name: '동대문구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-dongjak', name: '동작구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-mapo', name: '마포구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-seodaemun', name: '서대문구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-seocho', name: '서초구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-seongdong', name: '성동구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-seongbuk', name: '성북구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-songpa', name: '송파구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-yangcheon', name: '양천구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-yeongdeungpo', name: '영등포구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-yongsan', name: '용산구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-eunpyeong', name: '은평구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-jongno', name: '종로구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-jung', name: '중구', parentId: 'seoul', type: RegionType.district),
    Region(id: 'seoul-jungnang', name: '중랑구', parentId: 'seoul', type: RegionType.district),
    
    // 경기 시/군
    Region(id: 'gyeonggi-suwon', name: '수원시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-seongnam', name: '성남시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-goyang', name: '고양시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-yongin', name: '용인시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-bucheon', name: '부천시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-ansan', name: '안산시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-anyang', name: '안양시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-pyeongtaek', name: '평택시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-siheung', name: '시흥시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-gimpo', name: '김포시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-hwaseong', name: '화성시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-gwangju', name: '광주시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-paju', name: '파주시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-icheon', name: '이천시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-ansan-si', name: '안성시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-pocheon', name: '포천시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-uijeongbu', name: '의정부시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-yangju', name: '양주시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-guri', name: '구리시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-namyangju', name: '남양주시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-osan', name: '오산시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-hanam', name: '하남시', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-gapyeong', name: '가평군', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-yangpyeong', name: '양평군', parentId: 'gyeonggi', type: RegionType.district),
    Region(id: 'gyeonggi-yeoncheon', name: '연천군', parentId: 'gyeonggi', type: RegionType.district),
    
    // 부산 구
    Region(id: 'busan-haeundae', name: '해운대구', parentId: 'busan', type: RegionType.district),
    Region(id: 'busan-busanjin', name: '부산진구', parentId: 'busan', type: RegionType.district),
    Region(id: 'busan-dong', name: '동구', parentId: 'busan', type: RegionType.district),
    Region(id: 'busan-nam', name: '남구', parentId: 'busan', type: RegionType.district),
    Region(id: 'busan-buk', name: '북구', parentId: 'busan', type: RegionType.district),
    Region(id: 'busan-sasang', name: '사상구', parentId: 'busan', type: RegionType.district),
    Region(id: 'busan-saha', name: '사하구', parentId: 'busan', type: RegionType.district),
    Region(id: 'busan-seo', name: '서구', parentId: 'busan', type: RegionType.district),
    Region(id: 'busan-suyeong', name: '수영구', parentId: 'busan', type: RegionType.district),
    Region(id: 'busan-yeongdo', name: '영도구', parentId: 'busan', type: RegionType.district),
    Region(id: 'busan-jung', name: '중구', parentId: 'busan', type: RegionType.district),
    Region(id: 'busan-geumjeong', name: '금정구', parentId: 'busan', type: RegionType.district),
    Region(id: 'busan-gangseo', name: '강서구', parentId: 'busan', type: RegionType.district),
    Region(id: 'busan-gijang', name: '기장군', parentId: 'busan', type: RegionType.district),
    
    // 대구 구
    Region(id: 'daegu-jung', name: '중구', parentId: 'daegu', type: RegionType.district),
    Region(id: 'daegu-dong', name: '동구', parentId: 'daegu', type: RegionType.district),
    Region(id: 'daegu-seo', name: '서구', parentId: 'daegu', type: RegionType.district),
    Region(id: 'daegu-nam', name: '남구', parentId: 'daegu', type: RegionType.district),
    Region(id: 'daegu-buk', name: '북구', parentId: 'daegu', type: RegionType.district),
    Region(id: 'daegu-suseong', name: '수성구', parentId: 'daegu', type: RegionType.district),
    Region(id: 'daegu-dalseo', name: '달서구', parentId: 'daegu', type: RegionType.district),
    Region(id: 'daegu-dalseong', name: '달성군', parentId: 'daegu', type: RegionType.district),
    
    // 인천 구
    Region(id: 'incheon-jung', name: '중구', parentId: 'incheon', type: RegionType.district),
    Region(id: 'incheon-dong', name: '동구', parentId: 'incheon', type: RegionType.district),
    Region(id: 'incheon-michuhol', name: '미추홀구', parentId: 'incheon', type: RegionType.district),
    Region(id: 'incheon-yeonbyeong', name: '연수구', parentId: 'incheon', type: RegionType.district),
    Region(id: 'incheon-namdong', name: '남동구', parentId: 'incheon', type: RegionType.district),
    Region(id: 'incheon-bupyeong', name: '부평구', parentId: 'incheon', type: RegionType.district),
    Region(id: 'incheon-gyeeyang', name: '계양구', parentId: 'incheon', type: RegionType.district),
    Region(id: 'incheon-seo', name: '서구', parentId: 'incheon', type: RegionType.district),
    Region(id: 'incheon-ganghwa', name: '강화군', parentId: 'incheon', type: RegionType.district),
    Region(id: 'incheon-ongjin', name: '옹진군', parentId: 'incheon', type: RegionType.district),
    
    // 광주 구
    Region(id: 'gwangju-dong', name: '동구', parentId: 'gwangju', type: RegionType.district),
    Region(id: 'gwangju-seo', name: '서구', parentId: 'gwangju', type: RegionType.district),
    Region(id: 'gwangju-nam', name: '남구', parentId: 'gwangju', type: RegionType.district),
    Region(id: 'gwangju-buk', name: '북구', parentId: 'gwangju', type: RegionType.district),
    Region(id: 'gwangju-gwangsan', name: '광산구', parentId: 'gwangju', type: RegionType.district),
    
    // 대전 구
    Region(id: 'daejeon-dong', name: '동구', parentId: 'daejeon', type: RegionType.district),
    Region(id: 'daejeon-jung', name: '중구', parentId: 'daejeon', type: RegionType.district),
    Region(id: 'daejeon-seo', name: '서구', parentId: 'daejeon', type: RegionType.district),
    Region(id: 'daejeon-yuseong', name: '유성구', parentId: 'daejeon', type: RegionType.district),
    Region(id: 'daejeon-daedeok', name: '대덕구', parentId: 'daejeon', type: RegionType.district),
    
    // 울산 구
    Region(id: 'ulsan-jung', name: '중구', parentId: 'ulsan', type: RegionType.district),
    Region(id: 'ulsan-nam', name: '남구', parentId: 'ulsan', type: RegionType.district),
    Region(id: 'ulsan-dong', name: '동구', parentId: 'ulsan', type: RegionType.district),
    Region(id: 'ulsan-buk', name: '북구', parentId: 'ulsan', type: RegionType.district),
    Region(id: 'ulsan-ulju', name: '울주군', parentId: 'ulsan', type: RegionType.district),
    
    // 경남 시/군
    Region(id: 'gyeongnam-changwon', name: '창원시', parentId: 'gyeongnam', type: RegionType.district),
    Region(id: 'gyeongnam-jinju', name: '진주시', parentId: 'gyeongnam', type: RegionType.district),
    Region(id: 'gyeongnam-tongyeong', name: '통영시', parentId: 'gyeongnam', type: RegionType.district),
    Region(id: 'gyeongnam-sacheon', name: '사천시', parentId: 'gyeongnam', type: RegionType.district),
    Region(id: 'gyeongnam-gimhae', name: '김해시', parentId: 'gyeongnam', type: RegionType.district),
    Region(id: 'gyeongnam-miryang', name: '밀양시', parentId: 'gyeongnam', type: RegionType.district),
    Region(id: 'gyeongnam-geoje', name: '거제시', parentId: 'gyeongnam', type: RegionType.district),
    Region(id: 'gyeongnam-yangsan', name: '양산시', parentId: 'gyeongnam', type: RegionType.district),
    Region(id: 'gyeongnam-uiryeong', name: '의령군', parentId: 'gyeongnam', type: RegionType.district),
    Region(id: 'gyeongnam-haman', name: '함안군', parentId: 'gyeongnam', type: RegionType.district),
    Region(id: 'gyeongnam-changnyeong', name: '창녕군', parentId: 'gyeongnam', type: RegionType.district),
    Region(id: 'gyeongnam-goseong', name: '고성군', parentId: 'gyeongnam', type: RegionType.district),
    Region(id: 'gyeongnam-namhae', name: '남해군', parentId: 'gyeongnam', type: RegionType.district),
    Region(id: 'gyeongnam-hadong', name: '하동군', parentId: 'gyeongnam', type: RegionType.district),
    Region(id: 'gyeongnam-sancheong', name: '산청군', parentId: 'gyeongnam', type: RegionType.district),
    Region(id: 'gyeongnam-hamyang', name: '함양군', parentId: 'gyeongnam', type: RegionType.district),
    Region(id: 'gyeongnam-geochang', name: '거창군', parentId: 'gyeongnam', type: RegionType.district),
    Region(id: 'gyeongnam-hapcheon', name: '합천군', parentId: 'gyeongnam', type: RegionType.district),
    
    // 경북 시/군
    Region(id: 'gyeongbuk-pohang', name: '포항시', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-gyeongju', name: '경주시', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-gimcheon', name: '김천시', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-andong', name: '안동시', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-gumi', name: '구미시', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-yeongju', name: '영주시', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-yeongcheon', name: '영천시', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-sangju', name: '상주시', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-mungyeong', name: '문경시', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-gyeongsan', name: '경산시', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-gunwi', name: '군위군', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-uiseong', name: '의성군', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-cheongsong', name: '청송군', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-yeongyang', name: '영양군', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-yeongdeok', name: '영덕군', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-cheongdo', name: '청도군', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-goryeong', name: '고령군', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-seongju', name: '성주군', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-chilgok', name: '칠곡군', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-yechon', name: '예천군', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-bonghwa', name: '봉화군', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-uljin', name: '울진군', parentId: 'gyeongbuk', type: RegionType.district),
    Region(id: 'gyeongbuk-ulleung', name: '울릉군', parentId: 'gyeongbuk', type: RegionType.district),
    
    // 충남 시/군
    Region(id: 'chungnam-cheonan', name: '천안시', parentId: 'chungnam', type: RegionType.district),
    Region(id: 'chungnam-gongju', name: '공주시', parentId: 'chungnam', type: RegionType.district),
    Region(id: 'chungnam-boryeong', name: '보령시', parentId: 'chungnam', type: RegionType.district),
    Region(id: 'chungnam-asan', name: '아산시', parentId: 'chungnam', type: RegionType.district),
    Region(id: 'chungnam-seosan', name: '서산시', parentId: 'chungnam', type: RegionType.district),
    Region(id: 'chungnam-nonsan', name: '논산시', parentId: 'chungnam', type: RegionType.district),
    Region(id: 'chungnam-gyeryong', name: '계룡시', parentId: 'chungnam', type: RegionType.district),
    Region(id: 'chungnam-dangjin', name: '당진시', parentId: 'chungnam', type: RegionType.district),
    Region(id: 'chungnam-geumsan', name: '금산군', parentId: 'chungnam', type: RegionType.district),
    Region(id: 'chungnam-buyeo', name: '부여군', parentId: 'chungnam', type: RegionType.district),
    Region(id: 'chungnam-seocheon', name: '서천군', parentId: 'chungnam', type: RegionType.district),
    Region(id: 'chungnam-cheongyang', name: '청양군', parentId: 'chungnam', type: RegionType.district),
    Region(id: 'chungnam-hongseong', name: '홍성군', parentId: 'chungnam', type: RegionType.district),
    Region(id: 'chungnam-yesan', name: '예산군', parentId: 'chungnam', type: RegionType.district),
    Region(id: 'chungnam-taean', name: '태안군', parentId: 'chungnam', type: RegionType.district),
    
    // 충북 시/군
    Region(id: 'chungbuk-cheongju', name: '청주시', parentId: 'chungbuk', type: RegionType.district),
    Region(id: 'chungbuk-chungju', name: '충주시', parentId: 'chungbuk', type: RegionType.district),
    Region(id: 'chungbuk-jecheon', name: '제천시', parentId: 'chungbuk', type: RegionType.district),
    Region(id: 'chungbuk-boeun', name: '보은군', parentId: 'chungbuk', type: RegionType.district),
    Region(id: 'chungbuk-okcheon', name: '옥천군', parentId: 'chungbuk', type: RegionType.district),
    Region(id: 'chungbuk-yeongdong', name: '영동군', parentId: 'chungbuk', type: RegionType.district),
    Region(id: 'chungbuk-jeungpyeong', name: '증평군', parentId: 'chungbuk', type: RegionType.district),
    Region(id: 'chungbuk-jincheon', name: '진천군', parentId: 'chungbuk', type: RegionType.district),
    Region(id: 'chungbuk-goesan', name: '괴산군', parentId: 'chungbuk', type: RegionType.district),
    Region(id: 'chungbuk-eumseong', name: '음성군', parentId: 'chungbuk', type: RegionType.district),
    Region(id: 'chungbuk-danyang', name: '단양군', parentId: 'chungbuk', type: RegionType.district),
    
    // 전북 시/군
    Region(id: 'jeonbuk-jeonju', name: '전주시', parentId: 'jeonbuk', type: RegionType.district),
    Region(id: 'jeonbuk-gunsan', name: '군산시', parentId: 'jeonbuk', type: RegionType.district),
    Region(id: 'jeonbuk-iksan', name: '익산시', parentId: 'jeonbuk', type: RegionType.district),
    Region(id: 'jeonbuk-jeongeup', name: '정읍시', parentId: 'jeonbuk', type: RegionType.district),
    Region(id: 'jeonbuk-namwon', name: '남원시', parentId: 'jeonbuk', type: RegionType.district),
    Region(id: 'jeonbuk-gimje', name: '김제시', parentId: 'jeonbuk', type: RegionType.district),
    Region(id: 'jeonbuk-wanju', name: '완주군', parentId: 'jeonbuk', type: RegionType.district),
    Region(id: 'jeonbuk-jinan', name: '진안군', parentId: 'jeonbuk', type: RegionType.district),
    Region(id: 'jeonbuk-muju', name: '무주군', parentId: 'jeonbuk', type: RegionType.district),
    Region(id: 'jeonbuk-jangsu', name: '장수군', parentId: 'jeonbuk', type: RegionType.district),
    Region(id: 'jeonbuk-imsil', name: '임실군', parentId: 'jeonbuk', type: RegionType.district),
    Region(id: 'jeonbuk-sunchang', name: '순창군', parentId: 'jeonbuk', type: RegionType.district),
    Region(id: 'jeonbuk-gochang', name: '고창군', parentId: 'jeonbuk', type: RegionType.district),
    Region(id: 'jeonbuk-buan', name: '부안군', parentId: 'jeonbuk', type: RegionType.district),
    
    // 전남 시/군
    Region(id: 'jeonnam-mokpo', name: '목포시', parentId: 'jeonnam', type: RegionType.district),
    Region(id: 'jeonnam-yeosu', name: '여수시', parentId: 'jeonnam', type: RegionType.district),
    Region(id: 'jeonnam-suncheon', name: '순천시', parentId: 'jeonnam', type: RegionType.district),
    Region(id: 'jeonnam-naju', name: '나주시', parentId: 'jeonnam', type: RegionType.district),
    Region(id: 'jeonnam-gwangyang', name: '광양시', parentId: 'jeonnam', type: RegionType.district),
    Region(id: 'jeonnam-damyang', name: '담양군', parentId: 'jeonnam', type: RegionType.district),
    Region(id: 'jeonnam-gokseong', name: '곡성군', parentId: 'jeonnam', type: RegionType.district),
    Region(id: 'jeonnam-gurye', name: '구례군', parentId: 'jeonnam', type: RegionType.district),
    Region(id: 'jeonnam-goheung', name: '고흥군', parentId: 'jeonnam', type: RegionType.district),
    Region(id: 'jeonnam-boseong', name: '보성군', parentId: 'jeonnam', type: RegionType.district),
    Region(id: 'jeonnam-hwasun', name: '화순군', parentId: 'jeonnam', type: RegionType.district),
    Region(id: 'jeonnam-jangheung', name: '장흥군', parentId: 'jeonnam', type: RegionType.district),
    Region(id: 'jeonnam-gangjin', name: '강진군', parentId: 'jeonnam', type: RegionType.district),
    Region(id: 'jeonnam-haenam', name: '해남군', parentId: 'jeonnam', type: RegionType.district),
    Region(id: 'jeonnam-yeongam', name: '영암군', parentId: 'jeonnam', type: RegionType.district),
    Region(id: 'jeonnam-muan', name: '무안군', parentId: 'jeonnam', type: RegionType.district),
    Region(id: 'jeonnam-hampyeong', name: '함평군', parentId: 'jeonnam', type: RegionType.district),
    Region(id: 'jeonnam-yeonggwang', name: '영광군', parentId: 'jeonnam', type: RegionType.district),
    Region(id: 'jeonnam-jangseong', name: '장성군', parentId: 'jeonnam', type: RegionType.district),
    Region(id: 'jeonnam-wando', name: '완도군', parentId: 'jeonnam', type: RegionType.district),
    Region(id: 'jeonnam-jindo', name: '진도군', parentId: 'jeonnam', type: RegionType.district),
    Region(id: 'jeonnam-sinan', name: '신안군', parentId: 'jeonnam', type: RegionType.district),
    
    // 강원 시/군
    Region(id: 'gangwon-chuncheon', name: '춘천시', parentId: 'gangwon', type: RegionType.district),
    Region(id: 'gangwon-wonju', name: '원주시', parentId: 'gangwon', type: RegionType.district),
    Region(id: 'gangwon-gangneung', name: '강릉시', parentId: 'gangwon', type: RegionType.district),
    Region(id: 'gangwon-donghae', name: '동해시', parentId: 'gangwon', type: RegionType.district),
    Region(id: 'gangwon-taebaek', name: '태백시', parentId: 'gangwon', type: RegionType.district),
    Region(id: 'gangwon-sokcho', name: '속초시', parentId: 'gangwon', type: RegionType.district),
    Region(id: 'gangwon-samcheok', name: '삼척시', parentId: 'gangwon', type: RegionType.district),
    Region(id: 'gangwon-hongcheon', name: '홍천군', parentId: 'gangwon', type: RegionType.district),
    Region(id: 'gangwon-hoengseong', name: '횡성군', parentId: 'gangwon', type: RegionType.district),
    Region(id: 'gangwon-yeongwol', name: '영월군', parentId: 'gangwon', type: RegionType.district),
    Region(id: 'gangwon-pyeongchang', name: '평창군', parentId: 'gangwon', type: RegionType.district),
    Region(id: 'gangwon-jeongseon', name: '정선군', parentId: 'gangwon', type: RegionType.district),
    Region(id: 'gangwon-cheorwon', name: '철원군', parentId: 'gangwon', type: RegionType.district),
    Region(id: 'gangwon-hwacheon', name: '화천군', parentId: 'gangwon', type: RegionType.district),
    Region(id: 'gangwon-yanggu', name: '양구군', parentId: 'gangwon', type: RegionType.district),
    Region(id: 'gangwon-inje', name: '인제군', parentId: 'gangwon', type: RegionType.district),
    Region(id: 'gangwon-goseong', name: '고성군', parentId: 'gangwon', type: RegionType.district),
    Region(id: 'gangwon-yangyang', name: '양양군', parentId: 'gangwon', type: RegionType.district),
    
    // 제주 시/군
    Region(id: 'jeju-jeju', name: '제주시', parentId: 'jeju', type: RegionType.district),
    Region(id: 'jeju-seogwipo', name: '서귀포시', parentId: 'jeju', type: RegionType.district),
  ];

  /// 지역 ID로 지역 이름 가져오기
  static String getRegionName(String regionId) {
    final region = _regions.firstWhere(
      (r) => r.id == regionId,
      orElse: () => Region(id: regionId, name: regionId, type: RegionType.district),
    );
    
    // 부모 지역이 있으면 "부모 지역명 지역명" 형식으로 반환
    if (region.parentId != null) {
      final parent = _regions.firstWhere(
        (r) => r.id == region.parentId,
        orElse: () => Region(id: region.parentId!, name: '', type: RegionType.province),
      );
      if (parent.name.isNotEmpty) {
        return '${parent.name} ${region.name}';
      }
    }
    
    return region.name;
  }

  /// 모든 지역 목록 가져오기
  static List<Region> getAllRegions() {
    return List.unmodifiable(_regions);
  }

  /// 부모 ID로 하위 지역 목록 가져오기
  static List<Region> getDistrictsByProvince(String provinceId) {
    return _regions.where((r) => r.parentId == provinceId).toList();
  }
}
