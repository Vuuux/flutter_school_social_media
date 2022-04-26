import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/post.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/decoration.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/src/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as ImD;

import 'location_picker_screen.dart';

class UploadImage extends StatefulWidget {
  final UserData userData;
  File file;

  UploadImage({Key? key, required this.file, required this.userData})
      : super(key: key);

  @override
  _UploadImageState createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage>
    with AutomaticKeepAliveClientMixin<UploadImage> {
  File? file;
  TextEditingController descriptionTextEditingController =
      TextEditingController();
  TextEditingController locationController = TextEditingController();
  bool uploading = false;
  final Reference storageReference =
      FirebaseStorage.instance.ref().child("Đăng ảnh");
  final postReference = FirebaseFirestore.instance.collection("posts");
  String postId = const Uuid().v4();
  final GoogleSignIn googleSignIn = GoogleSignIn();

  //nén ảnh để hiển thị nhỏ
  compressPhoto() async {
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    ImD.Image? mImageFile = ImD.decodeImage(file!.readAsBytesSync());
    final compressedImage = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(ImD.encodeJpg(mImageFile!, quality: 60));
    setState(() {
      file = compressedImage;
    });
  }

  Future<String> uploadPhoto(mImageFile) async {
    UploadTask mStorageUploadTask =
        storageReference.child("post_$postId.jpg").putFile(mImageFile);
    TaskSnapshot storageTaskSnapshot = await mStorageUploadTask;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  getUserLocation() async {
    Position position = await _determinePosition().then((value) => value);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress =
        '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
    print("ADDRESS:" + completeAddress);
    String formattedAddress =
        "${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.country}";
    locationController.text = formattedAddress;
  }

  _getOtherUserLocation() async {
    Get.to(() => const LocationPicker());
  }

  Future controlUploadAndSave(String uid) async {
    setState(() {
      uploading = true;
    });

    await compressPhoto();

    String downloadUrl = await uploadPhoto(file);
    postId = const Uuid().v4();
    var response = await DatabaseServices(uid: uid).createPost(PostModel(
        postId: postId,
        username: widget.userData.username,
        timestamp: Timestamp.now(),
        ownerId: uid,
        description: descriptionTextEditingController.text,
        location: locationController.text,
        likes: {},
        url: downloadUrl));

    descriptionTextEditingController.clear();
    setState(() {
      // file = null;
      uploading = false;
    });

    response.fold((left) {
      Navigator.pop(context);
    }, (right) => {AlertDialog});
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
                  leading: CircleAvatar(
                    radius: 27,
                    child: ClipOval(
                      child: SizedBox(
                        width: 180,
                        height: 180,
                        child: Image.network(
                          widget.userData.avatar,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  title: TextFormField(
                    style: const TextStyle(color: Colors.black),
                    controller: descriptionTextEditingController,
                    decoration: textFieldInputDecoration(
                        ' Nói gì đó về ảnh của bạn đi'),
                    // decoration: InputDecoration(
                    //   hintText: 'Say something about your image',
                    //   hintStyle: TextStyle(color: Colors.grey),
                    //   border: InputBorder.none,
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.pin_drop,
                    color: kPrimaryColor,
                    size: 50,
                  ),
                  title: SizedBox(
                    width: 180,
                    child: TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                          hintText: "Tấm ảnh này được chụp ở đâu?",
                          border: InputBorder.none),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        child: RaisedButton.icon(
                          label: const Text(
                            "Dùng vị trí hiện tại",
                            style: TextStyle(color: Colors.white),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          color: kPrimaryColor,
                          onPressed: () {
                            getUserLocation();
                          },
                          icon: const Icon(Icons.location_on_outlined),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        child: RaisedButton.icon(
                          label: const Text(
                            "Chọn vị trí khác",
                            style: TextStyle(color: Colors.white),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          color: kPrimaryColor,
                          onPressed: () {
                            _getOtherUserLocation();
                          },
                          icon: const Icon(Icons.location_on_outlined),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
    );
  }

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
