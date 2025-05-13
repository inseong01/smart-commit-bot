# 작업일지 파일(영문 권장) - 한글 작성 시 파일명 깨짐
WORK_LOG_FILE="work-log.txt" 
# 커밋 파일
COMMIT_MSG_FILE="./commit-msg.txt"
# 작업 요약 함수 경로
SUMMARY_WORK_LOG_FILE="./auto/node/summary-work-log.js" 
# 작업 내역 추가 함수 경로
PAST_WORK_LOG_FILE="./auto/node/past-work-log.js"

trap "echo '자동 커밋 실행 종료'; exit 0" SIGINT

echo '>> 파일을 스테이징 영역에 추가 중...'
git add . 
echo -e '\n파일 스테이징 완료되었습니다.'

echo '>> Git 상태 및 변경 사항 파일 생성 중...'
git status --short | grep -vE "$WORK_LOG_FILE|.*ignore|.package-lock.json" > file-status.txt
git diff --cached -- . ":!$WORK_LOG_FILE" ":!.*ignore" ":!package-lock.json" ":!node_modules" > diff-files.txt
echo -e '\nGit 파일이 성공적으로 생성되었습니다.'

trap 'echo "첫번째 요약 에러가 발생하여 실행을 종료합니다."; exit 1' ERR

echo '>> 작업 로그 요약 중...'
node "$SUMMARY_WORK_LOG_FILE"
echo -e '\n요약이 완료되었습니다.'

while true; do
  echo '요약을 확인해주세요.'
  echo '---'
  cat "$COMMIT_MSG_FILE"
  echo -e '\n---'
  echo '>> 다시 요약할까요? (y/N)'

  read -r choice
  choice=${choice:-"n"}  # 기본값 N

  case "${choice,,}" in 
    y)
      trap 'echo "재실행 에러가 발생하여 실행을 종료합니다."; exit 1' ERR
    
      echo '다시 요약을 진행합니다.'
      node "$SUMMARY_WORK_LOG_FILE"
      echo '요약이 완료되었습니다.'
      ;;
    n | q)
      echo '요약을 유지합니다.'
      break 
      ;;
    *)
      echo '올바른 입력값(y/n)을 입력하세요!'
      ;;
  esac
done

echo -e '\n>> 자동 커밋을 실행할까요? (Y/n)'

while true; do
  read -r choice
  choice=${choice:-"y"}  # 기본값 Y

  case "${choice,,}" in 
    y)
      echo '자동 커밋을 진행합니다.'
      break;
      ;;
    n | q)
      echo '자동 커밋 진행을 종료합니다.'
      exit 0
      ;;
    *)
      echo '올바른 입력값(y/n)을 입력하세요!'
      ;;
  esac
done

trap 'echo "$WORK_LOG_FILE 업데이트 중 에러가 발생하여 실행을 종료합니다."; exit 1' ERR

echo -e "\n>> $WORK_LOG_FILE 업데이트 중..."
node "$PAST_WORK_LOG_FILE"
echo '파일이 업데이트 되었습니다.'

echo -e '\n>> 커밋 전에 다시 파일을 스테이징 하는 중...'
git add . 
echo '파일 스테이징 완료되었습니다.'

COMMIT_MESSAGE=$(<commit-msg.txt)
HEAD_COMMIT=$(echo "$COMMIT_MESSAGE" | head -n 1)
BODY_COMMIT=$(echo "$COMMIT_MESSAGE" | tail -n +4)

echo -e '\n>> 커밋 메시지 작성 중...'
git commit -m "$HEAD_COMMIT" -m "$BODY_COMMIT"
echo '커밋이 성공적으로 완료되었습니다!'

echo -e '\n>> 커밋 메시지를 확인하세요'
git log -1

CURRENT_BRANCH=$(git branch --show-current)
echo -e "\n>> $CURRENT_BRANCH 브랜치에 커밋을 푸시할까요? (Y/n)"

while true; do
  read -r choice
  choice=${choice:-"y"}  # 기본값 Y

  case "${choice,,}" in 
    y)
      trap 'echo "푸시 에러가 발생하여 실행을 종료합니다."; exit 1' ERR

      echo "'$CURRENT_BRANCH' 브랜치로 변경 사항을 푸시하는 중..."
      git push origin "$CURRENT_BRANCH"
      echo "푸시 완료!"
      break
      ;;
    n | q)
      echo "푸시를 취소합니다. 변경 사항은 로컬에만 유지됩니다."
      exit 0
      ;;
    *)
      echo "올바른 입력값(y/n)을 입력하세요!"
      ;;
  esac
done