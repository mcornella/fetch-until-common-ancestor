#!/bin/sh

branch1=$1 branch2=$2

# detach HEAD
git checkout --quiet --detach HEAD

# 1. Fetch both branch heads
git fetch --quiet --depth=1 origin $branch1:$branch1 $branch2:$branch2

# 2. If both branches are the same we're done
[ -n "$(git rev-list $branch1 $branch2)" ] || return

# 3. Fetch commits up until oldest branch head
date1=$(git show -s --format=%ct $branch1)
date2=$(git show -s --format=%ct $branch2)

if [ $date1 -gt $date2 ]; then
	oldest=$branch2
	oldest_date=$date2
else
	oldest=$branch1
	oldest_date=$date1
fi

git fetch --quiet --shallow-since=$oldest_date

# TODO: 4. Fix case where both heads are 1-commit apart (branches remain shallow)


# ? Should we fetch until common ancestor if branches diverge?
# ? Maybe not needed if diverged branches are not supported.
