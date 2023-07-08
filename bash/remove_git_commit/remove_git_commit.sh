#!/bin/bash

display_help() {
    echo "Usage: remove_git_commit.sh [branch_name] [commit_hash]"
    echo
    echo "   branch_name     The name of the branch where the commit is."
    echo "   commit_hash     The hash of the commit you want to remove."
    echo
    exit 1
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ -z "$1" ] || [ -z "$2" ]
then
    display_help
fi

BRANCH_NAME=$1
COMMIT_HASH=$2

git fetch origin
git checkout $BRANCH_NAME
git rebase --onto $COMMIT_HASH^ $COMMIT_HASH
git push origin $BRANCH_NAME --force
