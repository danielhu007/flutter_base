# Switch us to current script path and move two folders up
$script_path = $MyInvocation.MyCommand.Path
$windows_dir = Split-Path $script_path
$project_root_dir = "$windows_dir\..\.."
cd $project_root_dir
$script_exit_code = 0

Start-Process powershell -verb runas -ArgumentList "-file $windows_dir\lcov_dependencies_install.ps1" -Wait
refreshenv # We need to run this, because if the perl/choco is installed in previous step, the environmental variables change

Write-Output "Be patient please, this may take couple seconds..."

# Register all files to get real coverage including untested files
$output_file="$(pwd)/test/coverage_registrant_test.dart"
$package_name="$(cat pubspec.yaml| Select-String '^name: ')".replace('name: ', '')

#if [ "$package_name" = "" ]; then
  #  echo "Run $0 from the root of your Dart/Flutter project"
 #   exit 1
#fi

Write-Output "/// *** GENERATED FILE - ANY CHANGES WOULD BE OBSOLETE ON NEXT GENERATION *** ///" | Out-File -Encoding utf8 -FilePath "$output_file"
Write-Output "/// Helper to test coverage for all project files" | Out-File -Append -Encoding utf8 -FilePath "$output_file"
Write-Output "// ignore_for_file: unused_import" | Out-File -Append -Encoding utf8 -FilePath "$output_file"

$files = Get-ChildItem lib -Recurse -Name -Filter '*.dart' | Select-String -NotMatch '.g.dart' | Select-String -NotMatch '.part.dart' | Select-String -NotMatch 'generated_plugin_registrant'
foreach ($file in $files) {
  $file_fixed = "$file".replace('\', '/')
  Write-Output "import 'package:$package_name/$file_fixed';" | Out-File -Append -Encoding utf8 -FilePath "$output_file"
}
Write-Output "void main() {}" | Out-File -Append -Encoding utf8 -FilePath "$output_file"

$flutter_test_command = "flutter test --coverage"

Invoke-Expression $flutter_test_command # Done this way because we want to see the output in terminal
$script_exit_code = $LASTEXITCODE
Write-Output "Exit code for flutter test was: $script_exit_code"


$path_to_genhtml = "C:\ProgramData\chocolatey\lib\lcov\tools\bin\genhtml"
# Calling the GENHTML script
perl $path_to_genhtml -o coverage\html coverage\lcov.info

# Cleanup
rm "$output_file"

# Add a README.md to the coverage directory
$open_index_html = "Open index.html in any browser to display the lcov (test coverage) report."
Write-Output $open_index_html | Out-File -FilePath "coverage/README.md"

# Print to the console in the end
Write-Output "`n$open_index_html"

Exit $script_exit_code
