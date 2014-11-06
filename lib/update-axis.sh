#!/bin/bash

# Git subtree manager
# Alex Forencich <alex@alexforencich.com>
# This script facilitates easy management of subtrees
# included in larger repositories as this script can
# be included in the repository itself.

# Settings
# uncomment to use --squash
#squash="yes"
# Remote repository
repo="git@github.com:alexforencich/verilog-axis.git"
# Remote name
remote="axis"
# Subdirectory to store code in
# (relative to repo root or to script location)
#subdir="axis"
rel_subdir="axis"
# Remote branch
branch="master"
# Backport branch name (only used for pushing)
backportbranch="${remote}backport"
# Add commit message
addmsg="added ${remote} as a subproject"
# Merge commit message
mergemsg="merged changes in ${remote}"

# Usage
# add - adds subtree
# pull - default, pulls from remote
# push - pushes to remote

# determine repo absolute path
if [ -n "$rel_subdir" ]; then
    # cd to script dir
    SOURCE="${BASH_SOURCE[0]}"
    while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
      DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
      SOURCE="$(readlink "$SOURCE")"
      [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

    cd "$DIR"

    # relative path to script dir
    git-absolute-path () {
        fullpath=$(readlink -f "$1")
        gitroot="$(git rev-parse --show-toplevel)" || return 1
        [[ "$fullpath" =~ "$gitroot" ]] && echo "${fullpath/$gitroot\//}"
    }

    subdir="$(git-absolute-path .)/$rel_subdir"
fi

squashflag=""

cd $(git rev-parse --show-toplevel)

if [ $squash ]; then
    squashflag="--squash"
fi

action="pull"

if [ ! -d "$subdir" ]; then
    action="add"
fi

if [ -n "$1" ]; then
    action="$1"
fi

# array contains value
# usage: contains array value
function contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $n;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
}

case "$action" in
  add)
    if [ $(contains $(git remote) "$remote") != "y" ]; then
      git remote add "$remote" "$repo"
    fi
    git fetch "$remote"
    git subtree add -P "$subdir" $squashflag -m "$addmsg" "$remote/$branch"
    ;;
  pull)
    if [ $(contains $(git remote) "$remote") != "y" ]; then
      git remote add "$remote" "$repo"
    fi
    git fetch "$remote"
    git subtree merge -P "$subdir" $squashflag -m "$mergemsg" "$remote/$branch"
    ;;
  push)
    if [ $(contains $(git remote) "$remote") != "y" ]; then
      git remote add "$remote" "$repo"
    fi
    git subtree split -P "$subdir" -b "$backportbranch"
    git push "$remote" "$backportbranch:$branch"
    ;;
  *)
    echo "Error: unknown action!"
    exit 1
esac

exit 0

