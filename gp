#!/bin/bash
# Git Push
# Stage, Commit and Push Changes for Branch

function usage() {
  echo "Usage: $(basename $0) [-s SCOPE] <commit_type> <commit_message> [-h]"
  echo
  echo "Required Arguments:"
  echo "commit_type            The type of change being made in this commit. Allowed types described in: https://www.conventionalcommits.org/en/v1.0.0-beta.2/#summary"
  echo "commit_message         The message describing the change being made in this commit."
  echo
  echo "Optional Flags:"
  echo "-s SCOPE               (optional) Specifies a scope for this work within a project."
  echo "-h                     Displays this help dialog"

  exit 0
}

while getopts 'hs:' flag; do
  case "${flag}" in
    h) usage; exit 0 ;;
    s) SCOPE="$OPTARG"; shift $((OPTIND-1)) ;;
  esac
done

BRANCH_NAME=$(git branch | grep '*' | cut -d' ' -f2)
CHANGE_TYPE=${1}
MESSAGE=${@:2}

if [[ -z $CHANGE_TYPE ]]; then
  echo "[ERROR] A change type must be supplied"
  exit 1
fi

if [[ $CHANGE_TYPE != "feat" && $CHANGE_TYPE != "update" && $CHANGE_TYPE != "chore" && $CHANGE_TYPE != "fix" && $CHANGE_TYPE != "docs" && $CHANGE_TYPE != "refactor" && $CHANGE_TYPE != "test" && $CHANGE_TYPE != "perf" && $CHANGE_TYPE != "ci" && $CHANGE_TYPE != "build" && $CHANGE_TYPE != "init" ]]; then
  echo "[ERROR] The specified change type is not valid"
  echo "[ERROR] You must specify a change type described by: https://www.conventionalcommits.org/en/v1.0.0/#summary"
  exit 1
fi

if [[ -z $MESSAGE ]]; then
  echo "[ERROR] A message much be specified for this commit"
  exit 1
fi

COMMIT_MESSAGE="${CHANGE_TYPE}: $MESSAGE"
if [[ "$SCOPE" ]]; then
  COMMIT_MESSAGE="${CHANGE_TYPE}($SCOPE): $MESSAGE"
fi

if [[ -f "$(pwd)/.pre-commit-config.yaml" ]]; then
  echo "[INFO] This project uses Pre-Commit"
fi

gpa
git add -A
git commit -m "$COMMIT_MESSAGE"

git push 2> /dev/null

if [[ $? -ne 0 ]]; then
  echo "[INFO] push failed ... trying again with --set-upstream"
  git push --set-upstream origin $BRANCH_NAME

  if [[ $? -ne 0 ]]; then
    echo "[ERROR] could not push changes to remote ..."
    exit 1
  fi
fi
