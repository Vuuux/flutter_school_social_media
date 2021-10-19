
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/views/home/feed/upload_image_screen.dart';

class ChooseImage extends StatefulWidget {
  final BuildContext context;
  final UserData userData;

  const ChooseImage({Key? key, required this.context, required this.userData}) : super(key: key);

  @override
  _ChooseImageState createState() => _ChooseImageState();
}

pickImageFromGallery(context, userData) async {
  Navigator.pop(context);

  PickedFile? pickedFile = await ImagePicker()
      .getImage(source: ImageSource.gallery, maxHeight: 680, maxWidth: 970);
  File imageFile = File(
    pickedFile!.path,
  );
  if (imageFile == null) {
    // Navigator.of(context);
    // .pushAndRemoveUntil(
    //     FadeRoute(page: Wrapper()), ModalRoute.withName('Wrapper'));
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UploadImage(file: imageFile, userData: userData),
      ),
    );
  }
}

captureImageWithCamera(context, userData) async {
  Navigator.pop(context);
  PickedFile? pickedFile = await ImagePicker()
      .getImage(source: ImageSource.camera, maxHeight: 680, maxWidth: 970);
  File imageFile = File(pickedFile!.path);
  // File imageFile = await ImagePicker.pickImage(
  //     source: ImageSource.camera, maxHeight: 680, maxWidth: 970);
  if (imageFile == null) {
    // Navigator.of(context).pushAndRemoveUntil(
    //     FadeRoute(page: Wrapper()), ModalRoute.withName('Wrapper'));
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UploadImage(file: imageFile, userData: userData),
      ),
    );
  }
  if (imageFile == null) {
    // Navigator.of(context).pushAndRemoveUntil(
    //     FadeRoute(page: Wrapper()), ModalRoute.withName('Wrapper'));
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UploadImage(file: imageFile, userData: userData),
      ),
    );
  }
}

takeImage(nContext, userData) {
  return showDialog(
      context: nContext,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Thêm bài viết mới"),
          children: <Widget>[
            SimpleDialogOption(
              child: const Text(
                "Chụp bằng camera",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () => captureImageWithCamera(nContext, userData),
            ),
            SimpleDialogOption(
              child: const Text(
                "Chọn ảnh từ thư viện",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () => pickImageFromGallery(nContext, userData),
            ),
            SimpleDialogOption(
              child: const Text(
                "Đóng",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      });
}

class _ChooseImageState extends State<ChooseImage> {
  @override
  Widget build(BuildContext context) {
    return takeImage(widget.context, widget.userData);
  }
}

