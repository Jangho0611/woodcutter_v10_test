## 2026-06-22 PDF 출력 개선

### 작업 내용

* PDF 부품요약 페이지의 부품목록 출력 방식을 개선.
* 기존: 모든 부품을 세로 1열로 출력하여 항목 수가 많을 경우 A4 페이지 하단에서 잘림 발생.
* 변경: 부품 개수에 따라 자동으로 1~3열 배치.

### 출력 규칙

* 20개 이하: 1열 출력
* 21~45개: 2열 출력
* 46개 이상: 3열 출력

### 구현 위치

* `js/main-unified.js`
* 함수: `addSummaryPageAsImage(doc)`

### 구현 방식

* 기존 canvas 기반 PDF 생성 구조 유지.
* `labeledGroups.forEach()` 출력 로직만 수정.
* 열 수 자동 계산:

  * `columnCount`
  * `itemsPerColumn`
* 열 폭을 기준으로 좌표(`x`, `y`) 계산 후 출력.
* 3열 출력 시 기본 글자 크기 16px 적용.
* 긴 텍스트는 최소 12px까지 자동 축소.

### 테스트 결과

* 20개: 1열 정상 출력
* 45개: 2열 정상 출력
* 46개 이상: 3열 정상 출력
* A4 페이지 잘림 및 겹침 현상 없음

### 관련 커밋

* `0630910` - PDF 부품요약 목록 다열 배치 적용

## 2026-06-22 작업 기록

### 1. 기본 판재 두께 변경

#### 변경 내용

기본 판재 두께를 18mm에서 12mm로 변경.

#### 수정 파일

* `index.html`
* `index-mobile.html`
* `index-pc-old.html`
* `js/main-pc.js`
* `js/main-unified.js`
* `js/settingsManager.js`
* `js/costCalculator.js`

#### 결과

* 신규 프로젝트 생성 시 기본 두께 12mm 적용
* 서버/비 DOM fallback도 12mm로 통일

#### 관련 커밋

* `f0e16b2` - 기본 판재 두께 18mm를 12mm로 변경
* `2accecf` - 서버 환경 기본 판재 두께 fallback도 12mm로 통일

### 2. PDF 출력 개선

#### 문제

부품 개수가 많을 경우 PDF 요약 페이지의 부품목록이 A4 하단에서 잘림.

#### 원인

`addSummaryPageAsImage()` 함수가 부품목록을 세로 1열로만 출력.

#### 수정 위치

* `js/main-unified.js`
* 함수: `addSummaryPageAsImage(doc)`

#### 개선 내용

출력 규칙:

* 20개 이하: 1열
* 21~45개: 2열
* 46개 이상: 3열

구현 방식:

* `columnCount` 자동 결정
* `itemsPerColumn` 계산
* `columnIndex` / `rowIndex` 기반 좌표 계산

추가 개선:

* 3열 출력 시 기본 글자 크기 16px 적용
* 긴 텍스트는 최소 12px까지 자동 축소
* 기존 canvas + jsPDF 구조 유지

#### 테스트 결과

* 20개: 정상
* 45개: 정상
* 46개 이상: 정상
* A4 페이지 잘림 및 겹침 없음

#### 관련 커밋

* `0630910` - PDF 부품요약 목록 다열 배치 적용

### 3. UI 컬러 테마 변경 (한샘 오크 스타일)

#### 목표

기존 초록색 테마를 제거하고 밝은 오크 + 아이보리 기반의 한샘 스타일 UI 적용.

#### 수정 파일

* `css/responsive-style.css`
* `index.html`
* `js/main-unified.js`

#### 적용 테마

메인 컬러:

* `--color-primary: #CBB89D;`
* `--color-primary-dark: #8F7A63;`
* `--color-primary-light: #F8F5F0;`
* `--color-primary-hover: #B7A085;`
* `--color-bg: #F6F3EE;`
* `--color-border: #E5DDD1;`
* `--color-border-light: #F1EBE2;`
* `--color-text: #4C433B;`
* `--color-text-secondary: #7B7165;`

Gradient:

* `--gradient-primary: linear-gradient(135deg,#DDD1BF 0%,#CBB89D 55%,#A88F72 100%);`
* `--gradient-header: linear-gradient(135deg,#A88F72 0%,#8F7A63 100%);`
* `--gradient-cta: linear-gradient(135deg,#D8CCBA 0%,#CBB89D 100%);`

#### 추가 수정

빈 상태 SVG 색상 변경:

* `#48BB78` -> `#CBB89D`
* 연한 채움 -> `#DDD1BF`
* 강조 채움 -> `#A88F72`

계산 결과 그룹 헤더 Gradient 변경:

* `#48BB78` -> `#CBB89D`
* `#123628` -> `#8F7A63`

`PART_COLORS` 변경:

* `#DCFCE7` -> `#EFE3D4`
* `#ECFDF5` -> `#F8F5F0`

#### 결과

* 헤더: 오크톤 적용
* 버튼: 오크톤 적용
* 결과 카드: 오크톤 적용
* 중앙 SVG: 오크톤 적용
* 계산 결과 헤더: 오크톤 적용
* 중앙 도면: 초록색 제거
* 전체 UI: 한샘/리바트 스타일 통일 완료

#### 남은 작업

* 모바일(`css/style.css`) 테마 변경
* 구버전 PC(`css/pc-style.css`) 테마 변경
* 주석 내 Green 명칭 정리

#### Git 작업 주의

커밋 전:

```bash
git add docs/context.md css/responsive-style.css index.html js/main-unified.js
```

절대 사용 금지:

```bash
git add .
```

이유:

다른 프로젝트(`my-first-app/...`) 파일이 포함될 수 있음.
