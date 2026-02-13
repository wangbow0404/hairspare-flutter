import 'dart:ui' as ui;

/// SVG path 데이터를 Flutter Path로 변환하는 파서
/// React 라이브러리의 SVG path 형식을 정확하게 파싱합니다.
/// 여러 개의 sub-path (z로 닫히고 다시 m으로 시작하는 부분)를 지원합니다.
class SvgPathParser {
  /// SVG path 문자열을 Flutter Path 객체로 변환
  static ui.Path parse(String pathData) {
    final path = ui.Path();
    
    // z m 또는 z\s+m 패턴으로 sub-path 분리
    // 각 sub-path는 독립적으로 처리되어야 함
    // 더 견고한 패턴: z 다음에 공백이 있고 m으로 시작하는 경우 (대소문자 구분 없음)
    // 또는 z 다음에 바로 m이 오는 경우도 처리
    final subPathPattern = RegExp(r'z\s*(?=m)', caseSensitive: false);
    final parts = pathData.split(subPathPattern);
    
    for (int i = 0; i < parts.length; i++) {
      String subPathData = parts[i].trim();
      if (subPathData.isEmpty) continue;
      
      // 첫 번째가 아니면 앞에 'm' 추가 (분리할 때 제거되었으므로)
      if (i > 0) {
        subPathData = 'm $subPathData';
      }
      
      // z로 끝나지 않으면 z 추가 (sub-path를 닫기 위해)
      if (!subPathData.toLowerCase().endsWith('z')) {
        subPathData = '$subPathData z';
      }
      
      _parseSubPath(path, subPathData);
    }
    
    return path;
  }
  
  /// 개별 sub-path 파싱
  /// 각 sub-path는 독립적으로 처리되며, 좌표는 각 sub-path마다 초기화됨
  static void _parseSubPath(ui.Path path, String pathData) {
    // 정규식을 사용하여 명령어와 숫자를 분리
    // 명령어는 대소문자 구분, 숫자 부분은 명령어가 아닌 모든 문자
    final regex = RegExp(r'([MmLlHhVvZzCcSsQqTtAa])\s*([^MmLlHhVvZzCcSsQqTtAa]*)');
    final matches = regex.allMatches(pathData);
    
    // 각 sub-path마다 좌표 초기화 (독립적인 경로)
    double currentX = 0;
    double currentY = 0;
    double startX = 0;
    double startY = 0;
    bool isFirstMove = true; // 첫 번째 move 명령인지 추적
    
    for (final match in matches) {
      final command = match.group(1)!;
      final data = match.group(2)?.trim() ?? '';
      
      final isRelative = command == command.toLowerCase();
      final upperCmd = command.toUpperCase();
      
      // 숫자 추출 (음수, 소수점, 지수 표기법 지원)
      final numbers = _extractNumbers(data);
      
      switch (upperCmd) {
        case 'M': // MoveTo
          if (numbers.length >= 2) {
            for (int i = 0; i < numbers.length; i += 2) {
              if (i + 1 < numbers.length) {
                final x = numbers[i];
                final y = numbers[i + 1];
                
                // SVG 스펙: m (소문자)의 첫 번째 좌표 쌍은 절대 좌표로 처리됨
                if (isRelative && i == 0 && isFirstMove) {
                  // 첫 번째 좌표는 절대 좌표로 처리
                  currentX = x;
                  currentY = y;
                } else if (isRelative) {
                  // 그 이후의 좌표는 relative
                  currentX += x;
                  currentY += y;
                } else {
                  // M (대문자)는 항상 절대 좌표
                  currentX = x;
                  currentY = y;
                }
                
                // 첫 번째 move는 moveTo, 나머지는 lineTo
                if (i == 0 && isFirstMove) {
                  path.moveTo(currentX, currentY);
                  startX = currentX;
                  startY = currentY;
                  isFirstMove = false;
                } else {
                  path.lineTo(currentX, currentY);
                }
              }
            }
          }
          break;
          
        case 'L': // LineTo
          for (int i = 0; i < numbers.length; i += 2) {
            if (i + 1 < numbers.length) {
              final x = numbers[i];
              final y = numbers[i + 1];
              
              if (isRelative) {
                currentX += x;
                currentY += y;
              } else {
                currentX = x;
                currentY = y;
              }
              path.lineTo(currentX, currentY);
            }
          }
          break;
          
        case 'H': // Horizontal line
          for (final x in numbers) {
            if (isRelative) {
              currentX += x;
            } else {
              currentX = x;
            }
            path.lineTo(currentX, currentY);
          }
          break;
          
        case 'V': // Vertical line
          for (final y in numbers) {
            if (isRelative) {
              currentY += y;
            } else {
              currentY = y;
            }
            path.lineTo(currentX, currentY);
          }
          break;
          
        case 'Z': // ClosePath
        case 'z':
          path.close();
          currentX = startX;
          currentY = startY;
          // 다음 sub-path를 위해 첫 번째 move 플래그 리셋
          isFirstMove = true;
          break;
          
        default:
          // 기본적으로 l (lineTo relative)로 처리
          // 숫자가 있으면 lineTo로 처리
          if (numbers.isNotEmpty) {
            for (int i = 0; i < numbers.length; i += 2) {
              if (i + 1 < numbers.length) {
                final x = numbers[i];
                final y = numbers[i + 1];
                
                if (isRelative) {
                  currentX += x;
                  currentY += y;
                } else {
                  currentX = x;
                  currentY = y;
                }
                path.lineTo(currentX, currentY);
              }
            }
          }
      }
    }
  }
  
  /// 문자열에서 숫자를 추출 (음수, 소수점, 지수 표기법 지원)
  static List<double> _extractNumbers(String data) {
    if (data.isEmpty) return [];
    
    final numbers = <double>[];
    // 정규식: 부호 선택적, 숫자, 소수점 선택적, 지수 선택적
    // 공백, 쉼표로 구분된 숫자 추출
    final regex = RegExp(r'([+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?)');
    final matches = regex.allMatches(data);
    
    for (final match in matches) {
      final numStr = match.group(1);
      if (numStr != null) {
        final num = double.tryParse(numStr);
        if (num != null) {
          numbers.add(num);
        }
      }
    }
    
    return numbers;
  }
}
