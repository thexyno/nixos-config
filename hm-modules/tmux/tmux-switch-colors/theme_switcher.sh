#!/usr/bin/env bash

set -o errexit
set -o pipefail
[[ "${TRACE-0}" =~ ^1|t|y|true|yes$ ]] && set -o xtrace


[[ ! $(type -P "dark-notify") ]] && echo "dark-notify command not found. Exiting..." && exit 0
DN=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SCRIPT_NAME="$(basename $0)"

THEME_SETTER="$DN/theme_setter.sh"

if pgrep -qf "$SCRIPT_NAME"; then
        dark-notify -e -c "$THEME_SETTER" # run once
	exit 0
fi

while :; do
  dark-notify -c "$THEME_SETTER"
done
