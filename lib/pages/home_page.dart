import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import '../services/log_service.dart';
import 'details_page.dart';

class HomePage extends StatefulWidget {
  static const String id = "home_page";

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;
  List<Post> items = [];

  Future callDetailsPage() async {
    bool results = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return const DetailsPage();
    }));
    if (results) {
      _apiLoadPosts();
    }
  }

  _apiLoadPosts() async {
    setState(() {
      isLoading = true;
    });

    List<Post> posts = await DbService.loadPosts();
    LogService.i(posts.length.toString());
    setState(() {
      items = posts;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _apiLoadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        actions: [
          IconButton(
            onPressed: () {
              AuthService.signOutUser(context);
            },
            icon: Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return _itemOfPost(items[index]);
            },
          ),
          isLoading
              ? Center(
            child: CircularProgressIndicator(),
          )
              : SizedBox.shrink(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          callDetailsPage();
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _itemOfPost(Post post) {
    return Container(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            CachedNetworkImage(
              width: 70,
              height: 70,
              imageUrl: post.img_url!,
              placeholder: (context, url) => Container(
                color: Colors.grey.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.withOpacity(0.5),
              ),
              fit: BoxFit.cover,
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Text(
                  post.content,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ));
  }
}