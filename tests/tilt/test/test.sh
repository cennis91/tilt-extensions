#!/bin/bash

cd "$(dirname "$0")"

set -e

function run_test() {
    local test_name="$1"
    local fatal_on_fail="${2:-false}"
    local test_args=(--test-name "$test_name")

    if [[ "$fatal_on_fail" == "true" ]]; then
        test_args+=(--fatal-on-fail)
    fi

    tilt ci -- "${test_args[@]}"
    tilt down -- "${test_args[@]}" || {
        result="$?"
        # ignore the expected failure
        [[ "$fatal_on_fail" == "true" ]] && return 0
        return "$result"
    }
}

run_test "assert"
run_test "assert_fatal" "true"
run_test "assert_false"
run_test "assert_true"
