import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/loading.dart';
import 'package:luanvanflutter/views/authenticate/intro/filterpage.dart';
import 'package:provider/provider.dart';

import '../../../controller/controller.dart';
import '../../../models/user.dart';

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText;

  const CustomDialog({
    required this.title,
    required this.description,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    final user = Provider.of<CurrentUser?>(context);
    List<UserData> ctuerList;
    return StreamBuilder<Object>(
        stream: DatabaseServices(uid: user!.uid).userData,
        builder: (context, snapshot) {
          Object? userData = snapshot.data;
          if (userData != null) {
            return StreamBuilder<List<UserData>>(
                stream: DatabaseServices(uid: user.uid).ctuerList,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    ctuerList = snapshot.data!;

                    return Stack(
                      children: <Widget>[
                        Container(
                            padding: const EdgeInsets.only(
                                top: 100, bottom: 16, left: 14, right: 14),
                            margin: const EdgeInsets.only(top: 50),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(17),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 10),
                                  )
                                ]),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(title,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: kPrimaryColor)),
                                Text(description,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w100,
                                        color: Colors.black)),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => FilterPage(
                                              userData: userData as UserData,
                                              ctuerList: ctuerList),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'DZÔ',
                                      style: TextStyle(
                                          color: kPrimaryColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        const Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Colors.blueGrey,
                              radius: 60,
                              backgroundImage:
                                  AssetImage('assets/images/WTaB.gif'),
                            ))
                      ],
                    );
                  }
                  return Loading();
                });
          } else {
            return Loading();
          }
        });
  }
}
