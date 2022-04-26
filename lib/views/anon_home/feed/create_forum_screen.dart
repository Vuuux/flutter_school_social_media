import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/decoration.dart';
import 'package:luanvanflutter/views/components/chips/data/choice_chip_data.dart';
import 'package:luanvanflutter/views/components/chips/model/choice_chips.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/src/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as ImD;

class CreateForum extends StatefulWidget {
  final UserData userData;
  File file;

  CreateForum({Key? key, required this.file, required this.userData})
      : super(key: key);

  @override
  _CreateForumState createState() => _CreateForumState();
}

class _CreateForumState extends State<CreateForum>
    with AutomaticKeepAliveClientMixin<CreateForum> {
  File? file;
  TextEditingController descriptionTextEditingController =
      TextEditingController();
  TextEditingController titleTextEditingController = TextEditingController();
  bool uploading = false;
  final Reference storageReference =
      FirebaseStorage.instance.ref().child("Đăng ảnh");

  String forumId = const Uuid().v4();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  String category = "";
  //nén ảnh để hiển thị nhỏ
  compressPhoto() async {
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    ImD.Image? mImageFile = ImD.decodeImage(file!.readAsBytesSync());
    final compressedImage = File('$path/img_$forumId.jpg')
      ..writeAsBytesSync(ImD.encodeJpg(mImageFile!, quality: 60));
    setState(() {
      file = compressedImage;
    });
  }

  Future<String> uploadPhoto(mImageFile) async {
    UploadTask mStorageUploadTask =
        storageReference.child("forum_$forumId.jpg").putFile(mImageFile);
    TaskSnapshot storageTaskSnapshot = await mStorageUploadTask;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  controlUploadAndSave(String uid) async {
    setState(() {
      uploading = true;
    });

    await compressPhoto();

    String downloadUrl = await uploadPhoto(file);
    DatabaseServices(uid: uid).createForum(
        forumId,
        widget.userData.nickname,
        Timestamp.now(),
        uid,
        titleTextEditingController.text,
        descriptionTextEditingController.text,
        {},
        {},
        category,
        downloadUrl);

    descriptionTextEditingController.clear();
    setState(() {
      // file = null;
      uploading = false;
      forumId = Uuid().v4();
    });

    Navigator.pop(context, "UPLOADED");
  }

  displayUploadFormScreen(CurrentUserId user) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bài viết mới",
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          // uploading ? linearProgress() : Text(''),
          FlatButton(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onPressed: () => controlUploadAndSave(user.uid),
            child: const Text(
              "Chia sẻ",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: uploading
          ? Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : ListView(
              children: <Widget>[
                SizedBox(
                  height: 230,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: FileImage(file!), fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                ),
                ListTile(
                  leading: const Icon(Icons.title),
                  title: TextFormField(
                    style: const TextStyle(color: Colors.black),
                    controller: titleTextEditingController,
                    decoration: textFieldInputDecoration('Tựa đề diễn đàn'),
                    // decoration: InputDecoration(
                    //   hintText: 'Say something about your image',
                    //   hintStyle: TextStyle(color: Colors.grey),
                    //   border: InputBorder.none,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.question_answer),
                  title: TextFormField(
                    style: const TextStyle(color: Colors.black),
                    controller: descriptionTextEditingController,
                    decoration: textFieldInputDecoration(
                        'Đặt câu hỏi cho diễn đàn của bạn'),
                    // decoration: InputDecoration(
                    //   hintText: 'Say something about your image',
                    //   hintStyle: TextStyle(color: Colors.grey),
                    //   border: InputBorder.none,
                  ),
                ),
                buildChoiceChips()
              ],
            ),
    );
  }

  List<ChoiceChipData> choiceChips = ChoiceChips.all;

  Widget buildChoiceChips() => Wrap(
        runSpacing: 5.0,
        spacing: 5.0,
        alignment: WrapAlignment.center,
        children: choiceChips
            .map((choiceChip) => ChoiceChip(
                  label: Text(choiceChip.label!),
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  onSelected: (isSelected) => setState(() {
                    choiceChips = choiceChips.map((otherChip) {
                      final newChip = otherChip.copy(isSelected: false);

                      return choiceChip == newChip
                          ? newChip.copy(isSelected: isSelected)
                          : newChip;
                    }).toList();

                    switch (choiceChip.label) {
                      case 'Hỏi đáp':
                        category = 'questions';
                        break;
                      case 'Học tập':
                        category = 'studying';
                        break;
                      case 'Tư vấn':
                        category = 'advise';
                        break;
                      case 'Thầm kín':
                        category = 'secret';
                        break;
                      case 'Hỗ trợ':
                        category = 'support';
                        break;
                    }
                  }),
                  selected: choiceChip.isSelected,
                  selectedColor: kPrimaryColor,
                  backgroundColor: Colors.white,
                ))
            .toList(),
      );

  @override
  void initState() {
    file = widget.file;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUserId?>();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: displayUploadFormScreen(user!),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
