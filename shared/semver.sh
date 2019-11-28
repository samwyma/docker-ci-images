#!/bin/bash

inc_type=""
version_file=""
inline="false"

_echo_usage() {
  echo "Usage: $0 <mode> <version-file> [options]
Modes:
  major : Increments major version
  minor : Increments minor version
  patch : Increments patch version

Options:
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
  _version="$1"
  _error_msg="$2"
  if [[ ! "$_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "$2"
    exit 1
  fi
}

_get_segment() {
  cut -d. -f"$2" <<< "$1" | tr -d $'\n'
}

patch(){
 _version="$1"
 patch_ver="$(_get_segment "$_version" 3)"
 echo "$(_get_segment $_version 1).$(_get_segment $_version 2).$((patch_ver + 1))"
}

minor(){
 _version="$1"
 minor_ver="$(_get_segment "$_version" 2)"
 echo "$(_get_segment $_version 1).$((minor_ver + 1)).$(_get_segment $_version 3)"
}

major(){
 _version="$1"
 major_ver="$(_get_segment "$_version" 1)"
 echo "$((major_ver + 1)).$(_get_segment $_version 2).$(_get_segment $_version 3)"
}

for arg in "$@"
do
  case "$arg" in
    major|minor|patch)
      if [ "$inc_type" != "" ]; then
        _echo_usage
        exit 1
      fi
      inc_type="$arg"
      ;;
    -i)
      inline="true"
      ;;
    -h|--help)
      _echo_usage
      exit 0
      ;;
    *)
      version_file="$arg"
      ;; 
  esac
done

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