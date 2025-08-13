$chocolatey_command = "choco" # package manager
$perl_command = "perl" # perl is needed to run the lcov script

# Check if chocolatey package manager is installed
if (Get-Command $chocolatey_command -errorAction SilentlyContinue) {
    Write-Output "Chocolatey package manager is installed on your machine, continuing..."
}
else {
    Write-Output "Chocolatey installation will start in a sec."
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Check if perl is installed
# It is pre-requisity for the genhtml script (lcov) which is written in perl
# Lcov on windows: https://fredgrott.medium.com/lcov-on-windows-7c58dda07080
if (Get-Command $perl_command -errorAction SilentlyContinue) {
    Write-Output "Perl is installed on your machine, continuing..."
}
else {
    Write-Output "Strawberryperl installation will start in a sec."
    choco install strawberryperl -y # -y means confirm everything automatically
}

$path_to_genhtml = "C:\ProgramData\chocolatey\lib\lcov\tools\bin\genhtml"
# Check if lcov is installed
# Respectivelly, if GENHTML exists, which is lcov perl script that comes with lcov package
if (Test-Path -Path $path_to_genhtml) {
    Write-Output "GENHTML file exists."
}
else {
    Write-Output "GENHTML file was not found, installing lcov in a sec."
    choco install lcov -y # means confirm everything automatically
}