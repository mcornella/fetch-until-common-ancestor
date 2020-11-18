#!/usr/bin/env zsh
set -e

# Parse arguments
#   <num>: only execute test number <num>
#   --all: disable exit on error (runs all tests)
while [ $# -gt 0 ]; do
	case "$1" in
		<->) runtest=$1 ;;
		--all) set +e ;;
	esac
	shift
done

# utilities

abort() {
	printf "\n${RED}ABORT: $1${RESET}\n\n" >&2
	exit 1
}

colors() {
	RED=$(printf '\033[31m')
	GREEN=$(printf '\033[32m')
	WHITE=$(printf '\033[37m')
	BOLD=$(printf '\033[1m')
	RESET=$(printf '\033[0m')
}

colors

# test results

pass=0
fail=0

pass() {
	pass=$(( pass + 1 ))
	echo "${GREEN}pass${RESET}"
}

fail() {
	fail=$(( fail + 1 ))
	echo "${RED}fail${RESET}"
}

report_tests() {
	plural() {
		case $2 in
		1) echo $1 ;;
		*) echo ${1}s ;;
		esac
	}

	if [ $fail -eq 0 ]; then
		echo "All tests passed ($pass)."
	else
		echo -n "$pass $(plural test $pass) passed, "
		echo "$fail $(plural test $fail) failed."

		return 1
	fi
}

trap 'report_tests; exit $?' EXIT

# test running

test=0

test-should-run() {
	test=$(( test + 1 ))
	[ -z "$runtest" ] || [ $runtest -eq $test ]
}

root="$(cd "$(dirname $0)"; pwd)"

setup() {
	git-commit() {
		[ -z "$commitdate" ] && commitdate=1603659000 || commitdate=$(( commitdate + 1 ))
		GIT_COMMITTER_DATE="$commitdate" git commit --quiet --date "$commitdate" --allow-empty -m "$1"
	}

	# $1 = additional setup commands in remote repository

	# Clean up
	rm -rf "$root/remote" "$root/local"

	# Remote setup
	git init --quiet "$root/remote"
	cd "$root/remote"
	git-commit "Commit 1"
	git-commit "Commit 2"
	git-commit "Commit 3"
	git checkout --quiet -b master
	git-commit "master 1"
	git checkout --quiet main

	eval "$1"

	# Local setup
	git clone --quiet --depth=1 "file://$root/remote/.git" "$root/local"

	# Assert both repositories have been created
	test -d "$root/remote" || abort "setup: remote folder not found"
	test -d "$root/local" || abort "setup: local folder not found"
}

test_runner() {
	# $1 = description
	# $2 = remote repository setup
	# $3 = assertion

	echo -n "${WHITE}${BOLD}[$test] $1: ${RESET}"

	# Setup repositories
	setup "$2"

	# Run main algorithm inside local
	cd "$root/local" && "$root/fetch.sh" main master

	# Run assertion
	cd "$root"
	eval "$3"
}

test_expect_success() {
	if ! test-should-run; then
		return
	fi

	if ! test_runner "$1" "$2" "$3"; then
		fail
		return 1
	fi

	pass
}

test_expect_failure() {
	if ! test-should-run; then
		return
	fi

	if test_runner "$1" "$2" "$3"; then
		fail
		return 1
	fi

	pass
}

# Test runner tests
test_expect_success 'The test runner passes correctly' '' 'true'
test_expect_failure 'The test runner fails correctly' '' 'false'

# Algorithm tests
for testfile in "$root/tests"/*.sh; do
	test -f "$testfile" && . "$testfile"
done
