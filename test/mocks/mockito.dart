import 'package:flutter_base/features/counter/state/counter_provider.dart';
import 'package:flutter_base/features/posts/repositories/posts_repository.dart';
import 'package:flutter_base/repositories/database/external_repository.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  PostsRepository,
  ExternalRepository,
  CounterProvider,
])
void main() {}
