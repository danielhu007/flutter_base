import 'package:flutter_base/features/posts/models/post_model.dart';
import 'package:flutter_base/repositories/controllers/base_controller.dart';

class PostsRepository extends BaseController {
  PostsRepository({required super.baseUrl});

  Future<List<PostModel>> fetchPosts() async {
    final items = await getJsonList('/posts');
    return items.map((item) => PostModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}
