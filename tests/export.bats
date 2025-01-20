#!/usr/bin/env bats

setup() {
  load "$BATS_PLUGIN_PATH/load.bash"
}

@test "Exports metadata to env" {
  export BUILDKITE_PLUGIN_METADATA_ENV_KEYS_0="FOO"
  export BUILDKITE_PLUGIN_METADATA_ENV_KEYS_1="BAR"

  stub buildkite-agent \
    "meta-data get FOO : echo BAR" \
    "meta-data get BAR : echo TENDER"

  run $PWD/hooks/environment

  assert_success
  assert_output --partial "FOO=(3 chars)"
  assert_output --partial "BAR=(6 chars)"
}

@test "Exports remapped meta-data to env" {
  export BUILDKITE_PLUGIN_METADATA_ENV_KEYS_0="foo-meta=FOO_ENV"
  export BUILDKITE_PLUGIN_METADATA_ENV_KEYS_1="BAR"

  stub buildkite-agent \
    "meta-data get foo-meta : echo FIRST" \
    "meta-data get BAR : echo SECOND" \

  run $PWD/hooks/environment

  assert_success
  assert_output --partial "FOO_ENV=(5 chars)"
  assert_output --partial "BAR=(6 chars)"
}

@test "Properly handles optional exports" {
  export BUILDKITE_PLUGIN_METADATA_ENV_KEYS_0="A?"
  export BUILDKITE_PLUGIN_METADATA_ENV_KEYS_1="B?=ENV_B"
  export BUILDKITE_PLUGIN_METADATA_ENV_KEYS_2="C?"
  export BUILDKITE_PLUGIN_METADATA_ENV_KEYS_3="D?=ENV_D"

  stub buildkite-agent \
    "meta-data get A : echo A" \
    "meta-data get B : echo B"

  run $PWD/hooks/environment

  assert_success
  assert_output --partial "A=(1 chars)"
  assert_output --partial "ENV_B=(1 chars)"
  assert_output --partial "Meta-data key C not found, not setting C"
  assert_output --partial "Meta-data key D not found, not setting ENV_D"
}