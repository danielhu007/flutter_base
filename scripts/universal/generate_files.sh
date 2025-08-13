PROJECT_ROOT="$(dirname $0)"/../..

# Change dir to project root
cd $PROJECT_ROOT

## Generate files
dart run build_runner build --delete-conflicting-outputs

## Format generated files
dart format -l 120 test/mocks/mockito.mocks.dart lib/models/generated/*.g.dart lib/features/*/models/generated/*.g.dart
