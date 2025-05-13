import { GoogleGenAI } from '@google/genai';
import fs from 'node:fs/promises'
import dotenv from 'dotenv';
dotenv.config();

// Initialize Vertex with your Cloud project and location
const ai = new GoogleGenAI({
  vertexai: true,
  project: process.env.GOOGLE_PROJECT,
  location: 'us-west4',
});
const model = 'gemini-2.0-flash-001';
// Set up generation config
const generationConfig = {
  maxOutputTokens: 400,
  temperature: 0.2,
  topP: 0.95,
  responseModalities: ["TEXT"],
  safetySettings: [
    {
      category: 'HARM_CATEGORY_HATE_SPEECH',
      threshold: 'OFF',
    },
    {
      category: 'HARM_CATEGORY_DANGEROUS_CONTENT',
      threshold: 'OFF',
    },
    {
      category: 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
      threshold: 'OFF',
    },
    {
      category: 'HARM_CATEGORY_HARASSMENT',
      threshold: 'OFF',
    }
  ],
  systemInstruction: {
    parts: [{ "text": `커밋 메시지 작성기로서, 제공 받은 파일을 핵심 요약하여 커밋 메시지 반환` }]
  },
};

/**
 * diff, status 파일을 분석해 작업 내역 정리 함수
 */
export default async function analyzeWorkLog({ git_diff_text, git_status_text }) {
  const msg1Text1 = {
    text: `[제약 조건]
1. 모든 파일 경로는 생략하고 파일명만 사용하세요.
2. 헤더는 50자 이내로 작성하고, 동사 원형으로 시작하세요 (예: feat: 기능 추가, fix: 버그 수정).
3. 헤더 feat 동사는 코드 기능 추가일 때만 사용하세요.
4. 작업이 특정되지 않을 때는 chore를 사용하세요.
5. 본문은 리스트(-) 형식으로 작성하고, 변경 사항을 명확하게 설명하세요.
6. 리스트명은 파일명이나 파일 위치가 아니어야 합니다.
7. 강조 표시를 사용하지 마세요.
8. 요약이나 분석 내용을 출력하지 마세요.

[예시 1]
잘못된 예시: src/components/Button.js 파일 수정 (버튼 스타일 변경)
수정된 예시: fix: Button 스타일 변경

[예시 2]
optimize: 주문 및 요청 개선 

- 테이블 요청 이후, 주문 장바구니 초기화 상황 개선 
  - 전역 상태 추가하여 패치 모드 구분 
    
- 메인 페이지 개선 
  - 접속 시 초기 메뉴 카테고리 설정 
    
- 카테고리 설정 함수
  - useEffect -> 개별 버튼 onClick 설정 
    
  - 'main' 태그 높이 유동성 조정 
    
- 빌드 점검 완료 
  - 주문 결과 페이지 전환 시간 단축

[입력 파일]
${git_diff_text}
${git_status_text}


[출력]
커밋 메시지만 출력하세요.`
  };

  const chat = ai.chats.create({
    model: model,
    config: generationConfig
  });

  async function sendMessage(message) {
    const response = await chat.sendMessageStream({
      message: message
    });

    let content = ''

    for await (const chunk of response) {
      if (chunk.text) {
        // process.stdout.write(chunk.text);
        content += chunk.candidates[0].content.parts[0].text
      } else {
        // process.stdout.write(JSON.stringify(chunk) + '\n');
        content += '\n';
      }
    }

    await fs.writeFile('./commit-msg.txt', formatCommitLog(content.replaceAll('\`\`\`', '').trimStart()), { encoding: 'utf-8' });
    // console.log('content:', content)
  }

  async function generateContent() {
    await sendMessage([
      msg1Text1
    ]);
  }

  generateContent();
}

/**
 * 부모 카테고리 줄바꿈 함수
 * 
 * - 부모 카테고리, '-' 문자로 시작
 * - 자식 카테고리는 ' -' 공백이 포함돼 적용되지 않음
 * 
 */
function formatCommitLog(log) {
  return log
    .split("\n")  // 줄 단위로 분리
    .map((line) => {
      if (line.startsWith("-")) {
        return `\n${line}`;  // 부모 리스트만 줄바꿈
      }
      return line;  // 기존 형식 유지
    })
    .join("\n");  // 다시 문자열로 합치기
}
