#!/usr/bin/env bash

set -o errexit
set -o pipefail


DN=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

$DN/theme_switcher.sh
