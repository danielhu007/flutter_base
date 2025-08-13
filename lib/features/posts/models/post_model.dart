import 'package:json_annotation/json_annotation.dart';

part 'generated/post_model.g.dart';

@JsonSerializable()
class PostModel {
  final String title;

  PostModel({
    required this.title,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => _$PostModelFromJson(json);
}
