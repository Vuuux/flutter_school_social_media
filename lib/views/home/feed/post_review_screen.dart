import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/post.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/decoration.dart';
import 'package:luanvanflutter/utils/dimen.dart';
import 'package:luanvanflutter/views/components/aspect_video_player.dart';
import 'package:map_location_picker/google_map_location_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/src/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as ImD;
import 'package:video_player/video_player.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'location_picker_screen.dart';

class PreviewPostScreen extends StatefulWidget {
  final UserData userData;
  final List<XFile> files;
  final bool isMultipleImage;
  final bool isVideo;
  const PreviewPostScreen({
    Key? key,
    required this.files,
    required this.userData,
    this.isMultipleImage = true,
    this.isVideo = false,
  }) : super(key: key);

  @override
  _PreviewPostScreenState createState() => _PreviewPostScreenState();
}

class _PreviewPostScreenState extends State<PreviewPostScreen>
    with AutomaticKeepAliveClientMixin<PreviewPostScreen> {
  TextEditingController descriptionTextEditingController =
      TextEditingController();
  TextEditingController locationController = TextEditingController();
  bool uploading = false;
  final Reference storageReference =
      FirebaseStorage.instance.ref().child("Đăng ảnh");
  final postReference = FirebaseFirestore.instance.collection("posts");
  String postId = const Uuid().v4();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  List<Placemark> placemarks = [];
  Position? position;

  VideoPlayerController? _videoController;
  VideoPlayerController? _toBeDisposed;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0), () async {
      position = await _determinePosition().then((value) => value);
      placemarks = await placemarkFromCoordinates(
          position!.latitude, position!.longitude);
    });

    if (widget.isVideo) {
      _playVideo(widget.files[0]);
    }
  }

  // compressPhoto() async {
  //   final directory = await getTemporaryDirectory();
  //   final path = directory.path;
  //   ImD.Image? mImageFile = ImD.decodeImage(file!.readAsBytesSync());
  //   final compressedImage = File('$path/img_$postId.jpg')
  //     ..writeAsBytesSync(ImD.encodeJpg(mImageFile!, quality: 60));
  //   setState(() {
  //     file = compressedImage;
  //   });
  // }
  @override
  void deactivate() {
    if (_videoController != null) {
      _videoController!.setVolume(0.0);
      _videoController!.pause();
    }
    super.deactivate();
  }

  Future<void> _playVideo(XFile? file) async {
    if (_videoController != null) {
      await _videoController!.setVolume(0.0);
    }
    if (file != null && mounted) {
      await _disposeVideoController();
      late VideoPlayerController controller;
      controller = VideoPlayerController.file(File(file.path));
      _videoController = controller;
      const double volume = 1.0;
      await controller.setVolume(volume);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      setState(() {});
    }
  }

  Future<void> _disposeVideoController() async {
    if (_toBeDisposed != null) {
      await _toBeDisposed!.dispose();
    }
    _toBeDisposed = _videoController;
    _videoController = null;
  }

  Future<List<String>> uploadPhoto(
      {required List<XFile> mImageFiles,
      required bool isVideo,
      required bool isMultipleImage}) async {
    UploadTask mStorageUploadTask;
    List<String> downloadUrl = [];
    if (isMultipleImage && mImageFiles.length > 1) {
      int index = 0;
      await Future.forEach(mImageFiles, (XFile value) async {
        mStorageUploadTask = storageReference
            .child("post_${postId}_$index.jpg")
            .putFile(File(value.path));
        TaskSnapshot storageTaskSnapshot = await mStorageUploadTask;
        String url = await storageTaskSnapshot.ref.getDownloadURL();
        downloadUrl.add(url);
        index++;
      });
    } else if (!isVideo) {
      mStorageUploadTask = storageReference
          .child("post_$postId.jpg")
          .putFile(File(mImageFiles[0].path));
      TaskSnapshot storageTaskSnapshot = await mStorageUploadTask;
      String url = await storageTaskSnapshot.ref.getDownloadURL();
      downloadUrl.add(url);
    } else if (isVideo) {
      mStorageUploadTask = storageReference
          .child("post_video_$postId.mp4")
          .putFile(File(mImageFiles[0].path));
      TaskSnapshot storageTaskSnapshot = await mStorageUploadTask;
      String url = await storageTaskSnapshot.ref.getDownloadURL();
      downloadUrl.add(url);
    }
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
    Placemark placemark = placemarks[0];
    String completeAddress =
        '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
    print("ADDRESS:" + completeAddress);
    String formattedAddress =
        "${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.country}";
    locationController.text = formattedAddress;
  }

  _getOtherUserLocation() async {
    LocationResult? result = await showLocationPicker(
      context,
      "AIzaSyBkRBdX3_nLwpk2CwXO4CAkJbPMXuSFOPs",
      initialCenter: LatLng(position!.latitude, position!.latitude),
      myLocationButtonEnabled: true,
      layersButtonEnabled: true,
      countries: ['VN'],
    );
    locationController.text = result!.address;
    //Get.to(() => const LocationPicker());
  }

  Future controlUploadAndSave(String uid) async {
    setState(() {
      uploading = true;
    });

    //await compressPhoto();

    List<String> downloadUrl = await uploadPhoto(
        mImageFiles: widget.files,
        isVideo: widget.isVideo,
        isMultipleImage: widget.isMultipleImage);
    postId = const Uuid().v4();
    var response = await DatabaseServices(uid: uid).createPost(PostModel(
        postId: postId,
        username: widget.userData.username,
        timestamp: Timestamp.now(),
        ownerId: uid,
        description: descriptionTextEditingController.text,
        location: locationController.text,
        isVideo: widget.isVideo,
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
              shrinkWrap: true,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                    maxWidth: MediaQuery.of(context).size.width,
                  ),
                  child: Center(
                    child: widget.isVideo && _videoController != null
                        ? AspectRatioVideo(_videoController)
                        : widget.isMultipleImage
                            ? CarouselSlider(
                                items: widget.files
                                    .map((file) => Builder(builder: (context) {
                                          return Image.file(
                                            File(file.path),
                                            fit: BoxFit.cover,
                                          );
                                        }))
                                    .toList(),
                                options: CarouselOptions(
                                  height: 400,
                                  aspectRatio: 16 / 9,
                                  viewportFraction: 0.8,
                                  initialPage: 0,
                                  enableInfiniteScroll: false,
                                  reverse: false,
                                  autoPlay: true,
                                  autoPlayInterval: Duration(seconds: 3),
                                  autoPlayAnimationDuration:
                                      Duration(milliseconds: 800),
                                  autoPlayCurve: Curves.fastOutSlowIn,
                                  enlargeCenterPage: true,
                                  //onPageChanged: callbackFunction,
                                  scrollDirection: Axis.horizontal,
                                ))
                            : AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: FileImage(
                                            File(widget.files[0].path)),
                                        fit: BoxFit.cover),
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
                          onPressed: () async {
                            await _getOtherUserLocation();
                          },
                          icon: const Icon(Icons.location_on_outlined),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ).paddingOnly(top: Dimen.paddingCommon10),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = context.watch<CurrentUserId?>();
    return displayUploadFormScreen(user!);
  }

  @override
  bool get wantKeepAlive => true;
}
