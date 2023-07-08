#!/bin/bash

display_help() {
    echo "Usage: remove_git_commit.sh [commit_hash] [branch_name]"
    echo
    echo "   commit_hash     The hash of the commit you want to remove."
    echo "   branch_name     The name of the branch where the commit is."
    echo
    exit 1
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ -z "$1" ] || [ -z "$2" ]
then
    display_help
fi

COMMIT_HASH=$1
BRANCH_NAME=$2

git fetch origin
git checkout $BRANCH_NAME
git rebase --onto $COMMIT_HASH^ $COMMIT_HASH
git push origin $BRANCH_NAME --force
