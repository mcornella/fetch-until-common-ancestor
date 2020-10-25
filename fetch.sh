#!/bin/sh

branch1=$1 branch2=$2

# detach HEAD
git checkout --quiet --detach HEAD
# fetch both branch heads
git fetch --quiet --depth=2 origin $branch1:$branch1 $branch2:$branch2
# fetch commits up until $branch1 (if $branch1 is older)
git fetch --quiet --shallow-since=$(git show -s --format=%ct $branch1)
# fetch commits up until $branch2 (if $branch2 is older)
git fetch --quiet --shallow-since=$(git show -s --format=%ct $branch2)
# deepen branches
git fetch --quiet --deepen=2 origin $branch1 $branch2
# TODO: fetch common ancestor if branches diverge
