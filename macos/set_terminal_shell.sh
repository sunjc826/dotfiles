#!/usr/bin/env bash
# Make Terminal.app and iTerm2 open Homebrew bash, leaving the login shell (zsh) alone.

BASH_PATH=/opt/homebrew/bin/bash
# Must match the Guid in iterm2-bash-profile.json
ITERM_PROFILE_GUID=FA13BC71-5768-44D0-A8E9-387A4B663706

if [[ ! -x "$BASH_PATH" ]]
then
    echo "$BASH_PATH not found, run: brew install bash" >&2
    exit 1
fi

# Terminal > Settings > General > "Shells open with: Command"
defaults write com.apple.Terminal Shell -string "$BASH_PATH"
echo "Terminal.app: shell is now $(defaults read com.apple.Terminal Shell)"

if [[ -d /Applications/iTerm.app ]]
then
    defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "$ITERM_PROFILE_GUID"
    echo "iTerm2: default profile GUID is now $(defaults read com.googlecode.iterm2 "Default Bookmark Guid")"
fi

echo "Open a new window to pick it up. If an app reverts the setting after quitting, quit it and rerun this script."
