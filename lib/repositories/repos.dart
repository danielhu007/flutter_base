import 'package:flutter/material.dart';
import 'package:flutter_base/features/posts/repositories/posts_repository.dart';
import 'package:flutter_base/repositories/database/external_repository.dart';

abstract class Repos extends ChangeNotifier {
  PostsRepository get posts;
  ExternalRepository get external;
}

class ReposImpl extends ChangeNotifier implements Repos {
  @override
  final PostsRepository posts;
  @override
  final ExternalRepository external;

  ReposImpl({
    required this.posts,
    required this.external,
  });
}
