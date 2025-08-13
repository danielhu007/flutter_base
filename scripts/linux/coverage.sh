#!/bin/bash

##
## Runs all Flutter tests with coverage analysis mode, generating all necessary
## test coverage files.
##
## Note: The generated html files can be displayed in any browser by opening the coverage/index.html
##
## Inspired by: http://blog.wafrat.com/test-coverage-in-dart-and-flutter
##

PROJECT_ROOT="$(dirname $0)"/../..

# Install the test coverage tool if not installed
lcov -v
if [ $? != 0 ]
then
  ## If apt tool doesnt work, try brew tool (for MAC OS)
  sudo apt install lcov -y
  if [ $? != 0 ]
    then
      brew install lcov
      if [ $? != 0 ]
      then
	echo ""
        echo "Install HomeBrew on MacOS, then rerun the script"
        echo "https://www.makeuseof.com/tag/install-mac-software-terminal-homebrew/"
	echo ""
	exit 1
      fi
  fi
fi

# Change dir to project root
cd $PROJECT_ROOT

# Register all files to get real coverage including untested files
outputFile="$(pwd)/test/coverage_registrant_test.dart"
packageName="$(cat pubspec.yaml| grep '^name: ' | awk '{print $2}')"

if [ "$packageName" = "" ]; then
    echo "Run $0 from the root of your Dart/Flutter project"
    exit 1
fi

echo "/// *** GENERATED FILE - ANY CHANGES WOULD BE OBSOLETE ON NEXT GENERATION *** ///" > "$outputFile"
echo "/// Helper to test coverage for all project files" >> "$outputFile"
echo "// ignore_for_file: unused_import" >> "$outputFile"
find lib -name '*.dart' | grep -v '.g.dart' | grep -v '.part.dart' | grep -v 'generated_plugin_registrant' | awk -v package=$packageName '{gsub("^lib", "", $1); printf("import '\''package:%s%s'\'';\n", package, $1);}' >> "$outputFile"
echo "void main() {}" >> "$outputFile"

# Generate the basic lcov.info file
flutter test --coverage
RESULT=$? # Last command exit code

# From the basic file generate the html report files
genhtml coverage/lcov.info -o coverage

# Cleanup
rm "$outputFile"

# Add a README.md to the coverage directory
echo "Open index.html in any browser to display the lcov (test coverage) report" > coverage/README.md

# Print to the console where you can find the more detailed report
echo ""
echo "NOTE: Open coverage/index.html in any browser to display the detailed lcov (test coverage) report"

exit $RESULT
