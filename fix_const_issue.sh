#!/bin/bash

# MaterialPageRoute의 builder에서 const 제거 스크립트

cd /Users/yoram/hairspare_flutter

# 모든 Dart 파일에서 MaterialPageRoute(builder: (context) => const 를 MaterialPageRoute(builder: (context) => 로 변경
find lib/screens/spare -name "*.dart" -type f | while read file; do
    sed -i '' 's/MaterialPageRoute(builder: (context) => const/MaterialPageRoute(builder: (context) =>/g' "$file"
done

echo "✅ 모든 파일에서 const 키워드가 제거되었습니다."
