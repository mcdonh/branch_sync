#!/bin/bash

DATE=$(date)
get_rev_list="git rev-list --count develop..main"
find_conflict="git diff --name-only --diff-filter=U"
get_conflict_hash="git rev-parse HEAD"

AHEAD=$($get_rev_list)
commit_count=${#AHEAD[@]}
if [ $commit_count -ne 0 ]
then
  git checkout develop
  git merge main -m "merge on $DATE"
  CONFLICTS=$(git ls-files -u | wc -l)
  if [ "$CONFLICTS" -gt 0 ]
  then
    C_ID=$($find_conflict)
    C_HASH=$($get_conflict_hash)
    MESSAGE="conflict identified in file: ${C_ID} hash: ${C_HASH} auto-merge has been aborted"
    echo "$MESSAGE"
    git merge --abort
    exit 1
  fi
  git push
  echo deveop branch updated
fi

# --tags ?
# TAGSTAMP=`date +%Y-%m-%d.%H%M%S`
#  #echo "Tagging as ${TAGSTAMP}"
# #git tag -a $TAGSTAMP
# git push --tags
