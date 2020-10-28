assert_matching_revlists='
	git -C "$root/local" merge-base --is-ancestor main master || \
	git -C "$root/local" merge-base --is-ancestor master main
'

test_expect_failure 'Only fetches until newest common ancestor on diverged branches (1)' '
	git checkout --quiet master
	git-commit "master 2"
	git-commit "master 3"
	git checkout --quiet main
	git-commit "main 1"
' "$assert_matching_revlists"

test_expect_failure 'Only fetches until newest common ancestor on diverged branches (2)' '
	git checkout --quiet main
	git-commit "main 1"
' "$assert_matching_revlists"
