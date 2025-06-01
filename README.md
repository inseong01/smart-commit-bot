# Smart commit bot

`Gemini AI`를 활용한 작업 내역 요약 및 푸시 자동화 스크립트 파일입니다.

## 실행 흐름

1. `Git` 스테이징

2. `Gemini AI` 분석 및 요약 결과 출력

3. 재요약 여부 결정

4. 커밋 여부 결정

5. 커밋 내용 점검

6. 커밋 저장 및 저장소 반영

> 작업 내역은 `work-log.txt` 파일로 생성 및 업데이트 되며 `4번째 단계`에서 이뤄집니다.

## 실행 방법

### 파일 위치 이동

루트 디렉터리에 `auto` 폴더를 이동시켜주세요.

```
./auto/bash/commit-work-log.sh
```

### API Key 설정

`.env` 파일에 `GOOGLE_PROJECT` 값을 작성해주세요.

```
GOOGLE_PROJECT=<your-google-project-key>
```

### 패키지 설치

`Gemini AI`를 실행하기 위한 패키지를 설치해주세요.

```bash
npm run install -D @google/genai
```

### 스크립트 추가

`package.json` 파일에 스크립트 명령어를 하단과 같이 작성해주세요.

```
{
  "scripts": {
    "commit": "bash ./auto/bash/commit-work-log.sh"
  },
}
```

### 스크립트 실행

`bash` 터미널에서 스크립트 명령어를 실행해주세요.

```bash
npm run commit
```
