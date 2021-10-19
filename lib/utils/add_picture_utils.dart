import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:luanvanflutter/controller/controller.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/decoration.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/views/wrapper/wrapper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

//Thêm hình ảnh
class AddPicturesUtils extends StatefulWidget {
  const AddPicturesUtils({Key? key}) : super(key: key);

  @override
  _AddPicturesUtilsState createState() => _AddPicturesUtilsState();
}

class _AddPicturesUtilsState extends State<AddPicturesUtils> {
  File? _image;
  late String x;

  Future getImage() async {
    var image =
        await ImagePicker.platform.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image!.path);
    });
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUser>();
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              elevation: 0,
              titleSpacing: 50,
              leading: IconButton(
                  icon: const Icon(LineAwesomeIcons.home),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        FadeRoute(page: Wrapper()),
                        ModalRoute.withName('Wrapper'));
                  }),
            ),
            body: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height / 2,
                      child: (_image != null)
                          ? Image.file(
                              _image!,
                              fit: BoxFit.contain,
                            )
                          : Container(
                              color: Colors.white70,
                            ),
                    ),
                  ],
                ),
                IconButton(
                  color: Colors.cyan,
                  icon: const Icon(Icons.camera_alt, size: 30),
                  onPressed: () {
                    getImage();
                  },
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      loading = true;
                    });
                    Reference firebaseStorageReference =
                        FirebaseStorage.instance.ref().child(_image!.path);

                    UploadTask uploadTask =
                        firebaseStorageReference.putFile(_image!);
                    TaskSnapshot taskSnapshot = await uploadTask;
                    x = (await taskSnapshot.ref.getDownloadURL()).toString();
                    Map<String, dynamic> map = {
                      '0' : x
                    };

                    dynamic result =
                        DatabaseServices(uid: user.uid).uploadPhotos(map);

                    if (result != null) {
                      Navigator.of(context).pushAndRemoveUntil(
                          FadeRoute(page: Wrapper()),
                          ModalRoute.withName('Wrapper'));
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width / 2,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.blueGrey),
                    child: Text('Confirm', style: simpleTextStyle()),
                  ),
                ),
              ],
            ),
          );
  }
}
