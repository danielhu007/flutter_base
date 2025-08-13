#!/bin/bash

# Try to download newest git version
echo "Installing newest git version.."
OLD_GIT=$(git --version)
sudo add-apt-repository ppa:git-core/ppa
if [ $? == 0 ]
then
  sudo apt update
  sudo apt install git
else
  brew reinstall git
  if [ $? != 0 ]
  then
    echo ""
    echo "Install HomeBrew on MacOS, then rerun the script"
    echo "https://www.makeuseof.com/tag/install-mac-software-terminal-homebrew/"
    echo ""
    exit 1
  fi
fi

NEW_GIT=$(git --version)

#=========== Configure git ==========#
COMMIT_MSG_TEMPLATE=.gitmessage
GITHOOKS_DIR=.githooks

# Use the commit message template in your commits
git config commit.template "$COMMIT_MSG_TEMPLATE"

# Use githooks from a custom path
git config core.hooksPath "$GITHOOKS_DIR"
#===================================#

# Summarize
echo ""
echo ""
echo "========== SUMMARY =========="
echo "Your git has been updated:"
echo "$OLD_GIT -> $NEW_GIT"
echo ""
echo "Git configured successfully:"
echo "- commit message template"
echo "- git hooks dir"
