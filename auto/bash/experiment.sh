git reset
git add .

# file-status 제외 목록 확인
FILE_STATUS='./file-status.txt'
cat "$FILE_STATUS" | grep -vE 'work-log.txt|.*ignore|.package-lock.json' > file-status-1.txt
cat "$FILE_STATUS" | grep -vE 'work-log.txt|.package-lock.json' > file-status-2.txt

# diff-file 제외 목록 확인
# WORK_LOG_FILE="work-log.txt" 
# git diff --cached -- . ":!$WORK_LOG_FILE" ":!.gitignore" > diff-files-1.txt 
# git diff --cached -- . ":!$WORK_LOG_FILE" ":!.gitignore" ":!package-lock.json" ":!.prettierignore" > diff-files-2.txt 
# git diff --cached -- . ":!$WORK_LOG_FILE" ":!.*ignore" ":!package-lock.json" ":!node_modules" > diff-files-3.txt 