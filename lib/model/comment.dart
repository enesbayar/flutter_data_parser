import 'base_model.dart';

class Comment extends BaseModel {
  Comment({
    this.postId,
    this.id,
    this.name,
    this.email,
    this.body,
  });

  final int? postId;
  final int? id;
  final String? name;
  final String? email;
  final String? body;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        postId: json["postId"],
        id: json["id"],
        name: json["name"],
        email: json["email"],
        body: json["body"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "postId": postId,
        "id": id,
        "name": name,
        "email": email,
        "body": body,
      };
}
