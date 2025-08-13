PROJECT_ROOT="$(dirname $0)"/../..

# Change dir to project root
cd $PROJECT_ROOT

## Format dart code using "dart format"
dart format -l 120 lib test
