
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/post_model.dart';

class DbService {
  static final _firestore = FirebaseFirestore.instance;
  static String folder_posts = "posts";

  static Future<Post> storePost(Post post) async {
    String postId = _firestore.collection(folder_posts).doc().id;
    await _firestore.collection(folder_posts).doc(postId).set(post.toJson());
    return post;
  }

  static Future<List<Post>> loadPosts() async {
    List<Post> posts = [];

    var querySnapshot = await _firestore.collection(folder_posts).get();

    for (var result in querySnapshot.docs) {
      posts.add(Post.fromJson(result.data()));
    }
    return posts;
  }
}