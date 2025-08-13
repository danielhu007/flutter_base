# This script sets chmod=+x on all the .sh scripts in the project
# Windows sets it up to 644 automatically which strips down execution rights
# Linux devs then cannot execute them

# Switch us to current script path and move two folders up
$script_path = $MyInvocation.MyCommand.Path
$windows_dir = Split-Path $script_path
$project_root_dir = "$windows_dir\..\.."
cd $project_root_dir

$shell_scripts = git ls-files '*.sh'
foreach ($shell_script in $shell_scripts) {
    Write-Output("Setting chmod=+x on following script: $shell_script")
    git update-index --chmod=+x $shell_script
    git add $shell_script # It is then necessary to add it to the commit
}

# Just for a visual check - lists all the .sh scripts with the permissions representation on the left side
# It is expected that all the .sh scripts have 100755 value there
# 755 = rwxr-xr-x
# 644 = rw-r--r--
git ls-files '*.sh' --stage