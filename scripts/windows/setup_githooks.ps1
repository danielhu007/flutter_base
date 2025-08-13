$OLD_GIT = git --version
Write-Output "Your current version of git is: $OLD_GIT"

Write-Output "Installing newest git version.."
git update-git-for-windows
$NEW_GIT = git --version

# Switch us to current folder prior to the gitmessage, githooks settings
$script_path = $MyInvocation.MyCommand.Path
$dir = Split-Path $script_path
cd $dir

# =========== Configure git ========== #
$COMMIT_MSG_TEMPLATE = ".gitmessage"
$GITHOOKS_DIR = ".githooks"

# Use the commit message template in your commits
git config commit.template $COMMIT_MSG_TEMPLATE

# Use githooks from a custom path
git config core.hooksPath $GITHOOKS_DIR

# Enable auto CRLF line endings
git config core.autocrlf true
#===================================#

# Summarize
Write-Output "========== SUMMARY =========="
Write-Output "Your git has been updated:"
Write-Output "$OLD_GIT -> $NEW_GIT"
Write-Output ""
Write-Output "Git configured successfully."
Write-Output "Your git commit message is based on:"
git config commit.template
Write-Output "Your git core hooksPath is set to:"
git config core.hooksPath
Write-Output "Your git core autocrlf is set to:"
git config core.autocrlf
