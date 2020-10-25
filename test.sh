#!/bin/bash
set -e

root="$(cd "$(dirname $0)"; pwd)"

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

test=0
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
	fi
}

trap 'report_tests' EXIT

# test running

setup() {
	# Clean up
	cd "$root"
	rm -rf remote local

	# Remote setup
	git init --quiet remote
	git -C remote commit --quiet --allow-empty -m "Commit 1"
	git -C remote commit --quiet --allow-empty -m "Commit 2"
	git -C remote commit --quiet --allow-empty -m "Commit 3"
	git -C remote checkout --quiet -b master
	git -C remote commit --quiet --allow-empty -m "master 1"
	git -C remote checkout --quiet main

	# Local setup
	git clone --quiet --depth=1 file://$PWD/remote/.git local

	test -d "$root/remote" || abort "setup: remote folder not found"
	test -d "$root/local" || abort "setup: local folder not found"
}

test_runner() {
	# $1 = description
	# $2 = setup
	# $3 = assertion

	test=$(( test + 1 ))
	echo -n "${WHITE}${BOLD}[$test] $1: ${RESET}"

	# Setup repositories
	setup
	cd "$root/remote" && eval "$2"

	# Run main algorithm inside local
	cd "$root/local" && "$root/fetch.sh" main master

	# Run assertion
	cd "$root"
	eval "$3"
}

test_expect_success() {
	if ! test_runner "$1" "$2" "$3"; then
		fail
		return 1
	fi

	pass
}

test_expect_failure() {
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
