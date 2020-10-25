#!/bin/sh
set -e

root="$(cd "$(dirname $0)"; pwd)"

# utilities

abort() {
	printf "\n${RED}ABORT: $1${RESET}\n\n" >&4
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

tests=0
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
	exec 3>&1 4>&2 >/dev/null 2>&1

	# Clean up
	cd "$root"
	rm -rf remote local

	# Remote setup
	git init remote
	git -C remote commit --allow-empty -m "main 1"
	git -C remote commit --allow-empty -m "main 2"
	git -C remote checkout --quiet -b master
	git -C remote commit --allow-empty -m "master 1"
	git -C remote checkout --quiet main

	test -d "$root/remote" || abort "setup: remote folder not found"

	# Local setup
	git clone --depth=1 file://$PWD/remote/.git local

	test -d "$root/local" || abort "setup: local folder not found"

	# Cd into remote repository
	cd "$root/remote"

	exec >&3 2>&4 3>&- 4>&-
}

test_runner() {
	# $1 = description
	# $2 = setup
	# $3 = assertion
	# $4 = when to pass the test

	tests=$(( tests + 1 ))
	echo -n "${WHITE}${BOLD}[$tests] $1: ${RESET}"

	# Setup repositories
	setup && eval "$2"

	# Run main algorithm inside local
	cd "$root/local"
	"$root/fetch.sh" main master 2>/dev/null

	# Run assertion
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
test_expect_success 'the test runner passes correctly' '' 'true'
test_expect_failure 'the test runner fails correctly' '' 'false'
test_expect_success 'the test runner fails correctly' '' 'false'

# Algorithm tests
for testfile in "$root/tests"/*.sh; do
	test -f "$testfile" && . "$testfile"
done
