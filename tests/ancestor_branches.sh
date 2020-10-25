assert_matching_revlists='
	# Source: https://stackoverflow.com/a/42526347/5798232
	expected="$(cd "$root/remote"; git rev-list main master $(git merge-base main master)^!)"
	found="$(cd "$root/local"; git rev-list --all)"
	diff -u <(echo "$expected") <(echo "$found")
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
	git commit --quiet --allow-empty -m "main 1"
	git commit --quiet --allow-empty -m "main 2"
' "$assert_matching_revlists"
