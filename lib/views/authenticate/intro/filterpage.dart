import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:luanvanflutter/models/ctuer.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/decoration.dart';

import 'intro_page1.dart';


class Filterpage extends StatefulWidget {
  UserData userData;
  List<Ctuer> ctuerList;

  Filterpage({required this.userData, required this.ctuerList});
  @override
  _FilterpageState createState() => _FilterpageState();
}

class _FilterpageState extends State<Filterpage> {
  var isMaleSelected = true;
  var isFemaleSelected = false;
  var noresult= false;
  List<Ctuer> filtered = [];
  List<Ctuer> toremove = [];

  //List item
  final List<String> _majors = <String>[
    'Bất kì ngành nào!',
    'Công nghệ thông tin',
    'Tin học ứng dụng',
    'Công nghệ phần mềm',
    'Khoa học máy tính',
    'Hệ thống thông tin',
    'Mạng máy tính và truyền thông',
  ];

  List<String> _course = <String>['Bất kì khóa nào!','42', '43', '44', '45', '46'];

  late String selectedMajor, selectedGender, selectedCourse;


  @override
  void initState() {
    //add Male vào filtered, nếu là Female thì xóa
  widget.ctuerList.forEach((element) {
    if(element.gender == 'Male' && !filtered.contains(element)) {
      filtered.add(element);
    } else if (element.gender == 'Female') {
      filtered.remove(element);
    }
  });
  filtered.forEach((element) {
    print(element.name);
  });

  super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.95,
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.1,
                  left: 30,
                  right: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Tôi muốn làm quen với...",
                    style: TextStyle(
                      fontWeight: FontWeight.w100,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      InkWell(
                          onTap: () {
                            setState(() {
                              isMaleSelected = true;
                              isFemaleSelected = false;
                              selectedGender = "Male";
                            });
                            // widget.wiggles.forEach((element) {
                            //   if (element.gender == 'Male' &&
                            //       !filtered.contains(element)) {
                            //     filtered.add(element);
                            //   } else if (element.gender == 'Female') {
                            //     filtered.remove(element);
                            //   }

                            //   ;
                            // });

                            // filtered.forEach((element) {
                            //   print(element.name);
                            // });
                          },
                          child: ChoiceChip(
                              LineAwesomeIcons.male, 'Nam', isMaleSelected)),
                       InkWell(
                          onTap: () {
                            setState(() {
                              isMaleSelected = false;
                              isFemaleSelected = true;
                              selectedGender = "Female";
                            });

                            // widget.wiggles.forEach((element) {
                            //   if (element.gender == 'Female' &&
                            //       !filtered.contains(element)) {
                            //     filtered.add(element);
                            //   } else if (element.gender == 'Male') {
                            //     filtered.remove(element);
                            //   }
                            //   ;
                            // });

                            // filtered.forEach((element) {
                            //   print(element.name);
                            // });
                          },
                          child: ChoiceChip(
                              LineAwesomeIcons.female, 'Nữ', isFemaleSelected)),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      const Icon(
                        FontAwesomeIcons.book,
                        size: 25.0,
                        color: Colors.deepPurpleAccent,
                      ),
                      const SizedBox(width: 20.0),
                      Expanded(
                          child: DropdownButtonFormField(
                            items: _majors
                                .map((value) => DropdownMenuItem(
                              child: Text(
                                value,
                                style: TextStyle(color: Colors.deepPurpleAccent),
                              ),
                              value: value,
                            ))
                                .toList(),
                            onChanged: (selectmajor) {
                              setState(() {
                                selectedMajor = selectmajor as String;
                              });
                              //Xóa các ngành không được chọn ra khỏi filter
                              if (selectedMajor != 'Bất kì ngành nào!') {
                                filtered.forEach((element) {
                                  if(selectedCourse == null) {
                                    if (element.major != selectedMajor) {
                                      toremove.add(element);
                                    }
                                  }
                                  else {
                                    if(element.major != selectedMajor && element.course == selectedCourse){
                                      toremove.add(element);
                                    }
                                  }
                                });
                                filtered
                                    .removeWhere((element) => toremove.contains(element));
                              }
                            },
                            isExpanded: false,
                            decoration: textFieldInputDecoration('Ngành'),
                          )),
                      //Lọc khóa


                    ],
                  ),
                  Row(
                    children: <Widget>[
                      const Icon(
                      FontAwesomeIcons.idCard,
                      size: 25.0,
                      color: Colors.deepPurpleAccent,
                    ),
                      const SizedBox(width: 20.0),
                      Expanded(
                        child: DropdownButtonFormField(
                          items: _course
                              .map((value) => DropdownMenuItem(
                            child: Text(
                              value,
                              style: TextStyle(color: Colors.deepPurpleAccent),
                            ),
                            value: value,
                          ))
                              .toList(),
                          onChanged: (selectcourse) {
                            setState(() {
                              selectedCourse = selectcourse as String;
                            });
                            //Xóa các ngành không được chọn ra khỏi filter
                            if (selectedCourse != 'Bất kì khóa nào!') {
                              filtered.forEach((element) {
                                if(selectedMajor != null) {
                                  if (element.course != selectedCourse) {
                                    toremove.add(element);
                                  }
                                  else {
                                    if (element.course != selectedCourse && element.major == selectedMajor){
                                      toremove.add(element);
                                    }
                                  }
                                }
                              });
                              filtered
                                  .removeWhere((element) => toremove.contains(element));
                            }
                          },
                          isExpanded: false,
                          decoration: textFieldInputDecoration('Khóa'),
                        )),]

                  ),
                  FlatButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Text(
                          'Tìm',
                          style: TextStyle(
                            fontWeight: FontWeight.w100,
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      //xóa kết quả không phù hợp ra khỏi filter hoặc thêm kết quả phù hợp
                      if (selectedMajor != 'Bất kì ngành nào!' && selectedCourse!= 'Bất kì khóa nào!' &&
                          selectedMajor != null && selectedCourse!= null) {
                        widget.ctuerList.forEach((element) {
                          if (element.gender == selectedGender &&
                              element.major == selectedMajor &&
                              element.course == selectedCourse &&
                              !filtered.contains(element)) {
                            filtered.add(element);
                          } else if (element.gender != selectedGender ||
                              element.major != selectedMajor || element.course != selectedCourse) {
                            filtered.remove(element);
                          }
                          ;
                        });
                      } else if( selectedMajor == 'Bất kì ngành nào!' && selectedCourse == 'Bất kì khóa nào!'){
                        widget.ctuerList.forEach((element) {
                          if (element.gender == selectedGender &&
                              !filtered.contains(element)) {
                            filtered.add(element);
                          } else if (element.gender != selectedGender) {
                            filtered.remove(element);
                          }
                          ;
                        });
                      }

                      //Lọc khóa


                      if (filtered.isEmpty) {
                        setState(() {
                          noresult = true;
                        });
                        print('Không có kết quả!');
                      } else {
                        filtered.forEach((element) {
                          print(element.name);
                        });
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => IntroPage1(
                                userData: widget.userData, ctuerList: filtered),
                          ),
                        );
                      }
                    },
                  ),
                  noresult
                      ? Container(
                    child: const Text(
                      'Chưa tình thấy ai phù hợp, bạn thử tùy chọn khác xem!',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w200),
                    ),
                  )
                      : Container()
                ],
              ),
            )
          ],
        ));
  }
}

class ChoiceChip extends StatefulWidget {
  final IconData icon;
  final String text;
  final bool isSelected;

  ChoiceChip(this.icon, this.text, this.isSelected);
  @override
  _ChoiceChipState createState() => _ChoiceChipState();
}

class _ChoiceChipState extends State<ChoiceChip> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 5),
      decoration: widget.isSelected
          ? BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.all(Radius.circular(25.0)))
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Icon(
            widget.icon,
            size: 25,
            color: Colors.white,
          ),
          SizedBox(
            width: 8,
          ),
          Text(widget.text,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w100))
        ],
      ),
    );
  }
}