#!/usr/bin/env bats

@test "it errors if file does not exist" {
  run ./semver.sh patch non-existent
  [ "$status" -ne 0 ]
  [ "$output" = "Error: version file 'non-existent' does not exist" ]
}

@test "it errors if file does not contain valid version number" {
  echo "1..2.3" > non-semver
  run ./semver.sh patch non-semver
  [ "$status" -ne 0 ]
  [ "$output" = "Error: file 'non-semver' does not contain valid version" ]
  rm non-semver
}

@test "it increments patch version" {
  echo "1.2.3" > version
  run ./semver.sh patch version
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.4" ]
  rm version
}

@test "it increments minor version" {
  echo "1.2.3" > version
  run ./semver.sh minor version
  [ "$status" -eq 0 ]
  [ "$output" = "1.3.3" ]
  rm version
}

@test "it increments major version" {
  echo "1.2.3" > version
  run ./semver.sh major version
  [ "$status" -eq 0 ]
  [ "$output" = "2.2.3" ]
  rm version
}

@test "it increments version inline" {
  echo "1.2.3" > version
  run ./semver.sh -i patch version
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
  [ $(cat version) = "1.2.4" ]
  rm version
}

@test "it increments version inline with args rearranged" {
  echo "1.2.3" > version
  run ./semver.sh patch version -i
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
  [ $(cat version) = "1.2.4" ]
  rm version
}

@test "it prints help text when requested" {
  run ./semver.sh -i patch version -h
  [ "$status" -eq 0 ]
  [[ "$output" =~ Usage.* ]]
}

@test "it prints help text on multiple increment mode error" {
  run ./semver.sh -i patch major version
  [ "$status" -ne 0 ]
  [[ "$output" =~ Usage.* ]]
}

@test "it prints help text on no version file error" {
  run ./semver.sh -i patch
  [ "$status" -ne 0 ]
  [[ "$output" =~ Usage.* ]]
}