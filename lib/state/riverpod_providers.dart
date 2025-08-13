import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_base/features/counter/state/counter_provider.dart';
import 'package:flutter_base/features/posts/repositories/posts_repository.dart';
import 'package:flutter_base/repositories/database/external_repository.dart';
import 'package:flutter_base/repositories/repos.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Counter Provider
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier(100);
});

// External Repository Provider
final externalRepositoryProvider = Provider<ExternalRepository>((ref) {
  return ExternalRepository();
});

// Posts Repository Provider
final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  final apiUrl = dotenv.get('API_URL', fallback: '');
  return PostsRepository(baseUrl: apiUrl);
});

// Repos Provider
final reposProvider = Provider<Repos>((ref) {
  final externalRepo = ref.watch(externalRepositoryProvider);
  final postsRepo = ref.watch(postsRepositoryProvider);
  return ReposImpl(
    external: externalRepo,
    posts: postsRepo,
  );
});
