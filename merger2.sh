#!/bin/bash

export webhook=$1
DATE=$(date)
find_conflict="git diff --name-only --diff-filter=U"
get_conflict_hash="git rev-parse HEAD"
pip3 install pymsteams
cat << EOF > teams_webhook.py
#!/usr/bin/python3
import pymsteams
import sys
webhook = sys.argv[1]
message = ' '.join(sys.argv[2:])
mess_t = pymsteams.connectorcard(webhook)
mess_t.text(message)
mess_t.send()
EOF
chmod 755 teams_webhook.py
git fetch --unshallow
git checkout main
git pull
git push
git checkout develop
git pull
git push
git merge main -m "merge on $DATE"
CONFLICTS=$(git ls-files -u | wc -l)
if [ "$CONFLICTS" -gt 0 ]
then
  C_ID=$($find_conflict)
  C_HASH=$($get_conflict_hash)
  MESSAGE="conflict identified in file: ${C_ID} hash: ${C_HASH} auto-merge has been aborted"
  ./teams_webhook.py "$webhook" "$MESSAGE"
  git merge --abort
else
  git push
  echo develop branch synced
fi
