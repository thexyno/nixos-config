#!/usr/bin/env bash

DN=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [[ $1 == "dark" ]]; then
  tmux source-file $DN/dark.tmux
else
  tmux source-file $DN/light.tmux
fi
