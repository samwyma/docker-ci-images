#!/bin/bash

inc_type=""
version_file=""
beta_tag="beta"
inline="false"

_echo_usage() {
  echo "Usage: $0 <mode> <version-file> [options]
Modes:
  major : Increments major version
  minor : Increments minor version
  patch : Increments patch version
  beta : Increments beta version (e.g. 1.0.0-beta.1)

Options:
  -b          : Set custom beta tag (when incrementing beta version)
  -i          : Modify version file in place 
  -h, --help  : Display this help message
  "
}

_validate_file(){
  _version_file="$1"
  if [ -z "$_version_file" ]; then
    _echo_usage
    exit 1
  fi
  if [ ! -f "$_version_file" ]; then
    echo "Error: version file '$_version_file' does not exist"
    exit 1
  fi
}

_validate_version(){
  local _version="$1"
  local _error_msg="$2"
  if [[ ! "$_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z_]+\.[0-9]+)?$ ]]; then
    echo "$2"
    exit 1
  fi
}

_get_segment() {
  local separator="${3:-.}"
  cut -d"$separator" -f"$2" <<< "$1" | tr -d $'\n'
}

patch(){
 local _version="$1"
 local patch_ver="$(_get_segment "$_version" 3)"
 echo "$(_get_segment $_version 1).$(_get_segment $_version 2).$((patch_ver + 1))"
}

minor(){
 local _version="$1"
 local minor_ver="$(_get_segment "$_version" 2)"
 echo "$(_get_segment $_version 1).$((minor_ver + 1)).$(_get_segment $_version 3)"
}

major(){
 local _version="$1"
 local major_ver="$(_get_segment "$_version" 1)"
 echo "$((major_ver + 1)).$(_get_segment $_version 2).$(_get_segment $_version 3)"
}

beta(){
  local _version="$1"
  local main_version="$(_get_segment "$_version" 1 -)"
  if [[ "$_version" =~ - ]]; then
    local beta_seg="$(_get_segment "$_version" 2 -)"
    local current_beta_tag="$(_get_segment "$beta_seg" 1)"
    local beta_ver="$(_get_segment "$beta_seg" 2)"
    if [ "$current_beta_tag" != "$beta_tag" ]; then
      echo "Error: beta tag in version ($current_beta_tag) does not equal given beta tag ($beta_tag)" >&2
      exit 1
    fi
    echo "$main_version-${current_beta_tag}.$((beta_ver + 1))"
  else
    echo "${main_version}-${beta_tag}.0"
  fi
}

set -e

while (( "$#" )); do
  case "$1" in
    major|minor|patch|beta)
      if [ "$inc_type" != "" ]; then
        _echo_usage
        exit 1
      fi
      inc_type="$1"
      shift 1
      ;;
    -i)
      inline="true"
      shift 1
      ;;
    -b|--beta-tag)
      beta_tag="$2"
      if [[ ! "$beta_tag" =~ ^[a-zA-Z_]+$ ]]; then
        echo "Error: custom beta tag must only contain characters and underscores" >&2
        exit 1
      fi
      shift 2
      ;;
    -h|--help)
      _echo_usage
      exit 0
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *)
      version_file="$1"
      shift 1
      ;; 
  esac
done

# >&2 echo "$inc_type"

_validate_file "$version_file"

version="$(cat "$version_file")"
_validate_version "$version" "Error: file '$version_file' does not contain valid version"

new_version="$("$inc_type" "$version")"
_validate_version "$new_version" "Error: an unexpected error occurred"

if [ "$inline" == "true" ]; then
  echo "$new_version" > "$version_file" 
else
  echo "$new_version"
fi