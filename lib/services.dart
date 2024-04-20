// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class RequestHandler {
  Future fetchPost() async {
    final uri = Uri.parse("https://jsonplaceholder.typicode.com/posts/1");
    final response = await http.get(uri);
  }
}

class PostModel {
  final int userId;
  final String title;
  final String body;

  PostModel({required this.userId, required this.title, required this.body});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'title': title,
      'body': body,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      userId: map['userId'] as int,
      title: map['title'] as String,
      body: map['body'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory PostModel.fromJson(String source) =>
      PostModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class HomeController extends GetxController {
  var userData = <PostModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  fetchAll() async {
    try {
      var getUser = await RequestHandler().fetchPost();

      if (getUser != null) {
        userData.value = getUser;
      }
    } finally {
      isLoading(false);
    }
  }
}
