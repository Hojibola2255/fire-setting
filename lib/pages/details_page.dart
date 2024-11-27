import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/post_model.dart';
import '../services/db_service.dart';
import '../services/file_service.dart';
import '../services/log_service.dart';
import '../services/prefs_service.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool isLoading = false;
  var titleController = TextEditingController();
  var contentController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        LogService.e("No image selected");
      }
    });
  }

  _addNewPost() async {
    String title = titleController.text.toString().trim();
    String content = contentController.text.toString().trim();
    if (title.isEmpty || content.isEmpty) return;

    var userId = await Prefs.loadUserId();
    Post post = Post(userId, title, content, "");

    setState(() {
      isLoading = true;
    });

    _apiUploadImage(post);
  }

  _apiUploadImage(Post post) async{

    String img_url = await FileService.uploadPostImage(_image!);
    post.img_url = img_url;

    var result = await DbService.storePost(post);

    setState(() {
      isLoading = false;
    });

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Create Post"),
      ),
      body: Container(
          padding: EdgeInsets.all(20),
          child: Stack(
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      _getImage();
                    },
                    child: Container(
                      height: 150,
                      width: 150,
                      child: _image != null
                          ? Image.file(
                        _image!,
                        fit: BoxFit.cover,
                      )
                          : Image.asset("assets/images/ic_camera.png"),
                    ),
                  ),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(hintText: "Title"),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: contentController,
                    decoration: InputDecoration(hintText: "Content"),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: MaterialButton(
                      onPressed: () {
                        _addNewPost();
                      },
                      color: Colors.blue,
                      child: Text("Add"),
                    ),
                  ),
                ],
              ),
              isLoading
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : SizedBox.shrink(),
            ],
          )),
    );
  }
}