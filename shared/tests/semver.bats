#!/usr/bin/env bats

@test "it errors if file does not exist" {
  run ./semver.sh patch non-existent
  echo "$output"
  [ "$status" -ne 0 ]
  [ "$output" = "Error: version file 'non-existent' does not exist" ]
}

@test "it errors if file does not contain valid version number" {
  echo "1..2.3" > non-semver
  run ./semver.sh patch non-semver
  echo "$output"
  [ "$status" -ne 0 ]
  [ "$output" = "Error: file 'non-semver' does not contain valid version" ]
  rm non-semver
}

@test "it errors unsuppoerted flag given" {
  echo "1.2.3" > non-semver
  run ./semver.sh patch non-semver --not-a-flag
  echo "$output"
  [ "$status" -ne 0 ]
  [ "$output" = "Error: Unsupported flag --not-a-flag" ]
  rm non-semver
}

@test "it increments patch version" {
  echo "1.2.3" > version
  run ./semver.sh patch version
  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.4" ]
  rm version
}

@test "it increments minor version" {
  echo "1.2.3" > version
  run ./semver.sh minor version
  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" = "1.3.3" ]
  rm version
}

@test "it increments major version" {
  echo "1.2.3" > version
  run ./semver.sh major version
  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" = "2.2.3" ]
  rm version
}

@test "it adds beta version if none existed before" {
  echo "1.2.3" > version
  run ./semver.sh beta version
  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.3-beta.0" ]
  rm version
}

@test "it increments beta number if existed before" {
  echo "1.2.3-beta.10" > version
  run ./semver.sh beta version
  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.3-beta.11" ]
  rm version
}

@test "it fails on bad custom tag" {
  echo "1.2.3-custom-tag.10" > version
  run ./semver.sh beta version -b custom-tag
  echo "$output"
  [ "$status" -ne 0 ]
  [ "$output" = "Error: custom beta tag must only contain characters and underscores" ]
  rm version
}

@test "it adds custom beta tag if none existed before" {
  echo "1.2.3" > version
  run ./semver.sh beta version -b custom_tag
  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.3-custom_tag.0" ]
  rm version
}

@test "it increments custom beta tag if existed before" {
  echo "1.2.3-custom_tag.10" > version
  run ./semver.sh beta version -b custom_tag
  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" = "1.2.3-custom_tag.11" ]
  rm version
}

@test "it errors if beta tag differnt from given custom tag" {
  echo "1.2.3-not_same.10" > version
  run ./semver.sh beta version -b custom_tag
  echo "$output"
  [ "$status" -eq 1 ]
  [ "$output" = "Error: beta tag in version (not_same) does not equal given beta tag (custom_tag)" ]
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
  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
  [ $(cat version) = "1.2.4" ]
  rm version
}

@test "it prints help text when requested" {
  run ./semver.sh -i patch version -h
  echo "$output"
  [ "$status" -eq 0 ]
  [[ "$output" =~ Usage.* ]]
}

@test "it prints help text on multiple increment mode error" {
  run ./semver.sh -i patch major version
  echo "$output"
  [ "$status" -ne 0 ]
  [[ "$output" =~ Usage.* ]]
}

@test "it prints help text on no version file error" {
  run ./semver.sh -i patch
  echo "$output"
  [ "$status" -ne 0 ]
  [[ "$output" =~ Usage.* ]]
}