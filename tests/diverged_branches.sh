assert_matching_revlists='
	# Source: https://stackoverflow.com/a/42526347/5798232
	expected="$(cd "$root/remote"; git rev-list main master $(git merge-base main master)^!)"
	found="$(cd "$root/local"; git rev-list --all)"
	diff -u <(echo "$expected") <(echo "$found")
'

test_expect_success 'Only fetches until newest common ancestor on diverged branches (1)' '
	git checkout --quiet master
	git-commit "master 2"
	git-commit "master 3"
	git checkout --quiet main
	git-commit "main 1"
' "$assert_matching_revlists"

test_expect_success 'Only fetches until newest common ancestor on diverged branches (2)' '
	git checkout --quiet main
	git-commit "main 1"
' "$assert_matching_revlists"
