# file-status 제외 목록 확인
# FILE_STATUS='./file-status.txt'
# cat "$FILE_STATUS" | grep -vE 'work-log.txt|.gitignore|.package-lock.json|.prettierignore'

# diff-file 제외 목록 확인
git diff --cached -- . ":!$WORK_LOG_FILE" ":!.gitignore" ":!package-lock.json" ":!.prettierignore" > diff-files.txt 
git diff --cached -- . ":!$WORK_LOG_FILE" ":!.*ignore" ":!package-lock.json" > diff-files.txt 