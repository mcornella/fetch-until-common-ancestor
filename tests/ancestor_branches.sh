assert_matching_revlists='
	# Source: https://stackoverflow.com/a/42526347/5798232
	expected="$(cd "$root/remote"; git rev-list main master $(git merge-base main master)^!)"
	found="$(cd "$root/local"; git rev-list --all)"
	diff -u <(echo "$expected") <(echo "$found") && \
	git -C "$root/local" merge-base main master >/dev/null 2>&1
'

test_expect_success 'Only fetches one commit if main and master are the same' '
	git checkout --quiet main
	git reset --quiet --hard master
' "$assert_matching_revlists"

test_expect_success 'Only fetches until main if ancestor of master' '
' "$assert_matching_revlists"

test_expect_success 'Only fetches until master if ancestor of main' '
	git checkout --quiet main
	git reset --quiet --hard master
	git-commit "main 1"
' "$assert_matching_revlists"

test_expect_success 'Fetches until main with 2 commits of difference' '
	git checkout --quiet master
	git-commit "master 2"
' "$assert_matching_revlists"

test_expect_success 'Fetches until master with 2 commits of difference' '
	git checkout --quiet main
	git reset --quiet --hard master
	git-commit "main 1"
	git-commit "main 2"
' "$assert_matching_revlists"
