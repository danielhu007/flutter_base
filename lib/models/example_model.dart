import 'package:json_annotation/json_annotation.dart';

part 'generated/example_model.g.dart';

@JsonSerializable()
class ExampleModel {
  final String name;

  ExampleModel({
    required this.name,
  });

  factory ExampleModel.fromJson(Map<String, dynamic> json) => _$ExampleModelFromJson(json);
}
