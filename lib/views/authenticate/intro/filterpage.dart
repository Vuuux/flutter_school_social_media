import 'package:eventual/eventual-notifier.dart';
import 'package:eventual/eventual-single-builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:luanvanflutter/models/ctuer.dart';
import 'package:luanvanflutter/models/user.dart';
import 'package:luanvanflutter/style/constants.dart';
import 'package:luanvanflutter/style/decoration.dart';
import 'package:luanvanflutter/utils/dimen.dart';

import 'intro_page1.dart';

class FilterPage extends StatefulWidget {
  UserData userData;
  List<UserData> ctuerList;

  FilterPage({Key? key, required this.userData, required this.ctuerList})
      : super(key: key);
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  var noResult = false;
  EventualNotifier<List<UserData>> filtered =
      EventualNotifier<List<UserData>>([]);
  EventualNotifier<bool> _isMaleSelected = EventualNotifier<bool>(true);
  EventualNotifier<String> _selectedMajor = EventualNotifier<String>();
  EventualNotifier<String> _selectedCourse = EventualNotifier<String>();
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

  final List<String> _course = <String>[
    'Bất kì khóa nào!',
    (DateTime.now().year - 2005 + 26).toString(),
    (DateTime.now().year - 2005 + 27).toString(),
    (DateTime.now().year - 2005 + 28).toString(),
    (DateTime.now().year - 2005 + 29).toString(),
    (DateTime.now().year - 2005 + 30).toString()
  ];

  @override
  void initState() {
    _selectedMajor.value = _majors[0];
    _selectedCourse.value = _course[0];
    super.initState();
  }

  _handleSearch() {
    String resultGender = _isMaleSelected.value ? 'Male' : 'Female';
    List<UserData> resultList = widget.ctuerList;
    resultList.removeWhere((element) => element.gender != resultGender);
    if (_selectedMajor.value != _majors[0]) {
      resultList
          .removeWhere((element) => element.major != _selectedMajor.value);
    }

    if (_selectedCourse.value != _course[0]) {
      resultList
          .removeWhere((element) => element.course != _selectedCourse.value);
    }
    if (resultList.isEmpty) {
      Get.snackbar(
          "Rất tiếc", "Không có kết quả nào phù hợp tìm kiếm của bạn :(",
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              IntroPage1(userData: widget.userData, ctuerList: resultList),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        EventualSingleBuilder(
            notifier: _isMaleSelected,
            builder: (context, notifier, _) {
              return Container(
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
                    const Text(
                      "Tôi muốn làm quen với...",
                      style: TextStyle(
                        fontWeight: FontWeight.w100,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        FilterChip(
                          avatar: const Icon(LineAwesomeIcons.male),
                          label: Text('Nam'),
                          selected: notifier.value ? true : false,
                          selectedColor: (Get.isDarkMode
                                  ? kPrimaryDarkColor
                                  : kPrimaryColor)
                              .withOpacity(0.6),
                          onSelected: (bool value) {
                            _isMaleSelected.value = true;
                            _isMaleSelected.notifyChange();
                          },
                        ),
                        FilterChip(
                          avatar: const Icon(LineAwesomeIcons.female),
                          label: Text('Nữ'),
                          selectedColor: (Get.isDarkMode
                                  ? kPrimaryDarkColor
                                  : kPrimaryColor)
                              .withOpacity(0.6),
                          selected: !notifier.value ? true : false,
                          onSelected: (bool value) {
                            _isMaleSelected.value = false;
                            _isMaleSelected.notifyChange();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.book,
                          size: 25.0,
                          color: Get.isDarkMode
                              ? kPrimaryDarkColor
                              : kPrimaryColor,
                        ),
                        const SizedBox(width: 20.0),
                        Expanded(
                            child: DropdownButtonFormField(
                          items: _majors
                              .map((value) => DropdownMenuItem<String>(
                                    child: Text(
                                      value,
                                    ),
                                    value: value,
                                  ))
                              .toList(),
                          onChanged: (selectMajor) {
                            _selectedMajor.value = selectMajor.toString();
                          },
                          value: _selectedMajor.value,
                          isExpanded: false,
                          decoration: textFieldInputDecoration('Ngành'),
                        )),
                        //Lọc khóa
                      ],
                    ),
                    Row(children: <Widget>[
                      Icon(
                        FontAwesomeIcons.idCard,
                        size: 25.0,
                        color:
                            Get.isDarkMode ? kPrimaryDarkColor : kPrimaryColor,
                      ),
                      const SizedBox(width: 20.0),
                      Expanded(
                          child: DropdownButtonFormField(
                        items: _course
                            .map((value) => DropdownMenuItem<String>(
                                  child: Text(
                                    value,
                                  ),
                                  value: value,
                                ))
                            .toList(),
                        onChanged: (selectCourse) {
                          _selectedCourse.value = selectCourse.toString();
                        },
                        value: _selectedCourse.value,
                        isExpanded: false,
                        decoration: textFieldInputDecoration('Khóa'),
                      )),
                    ]),
                    FlatButton(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Container(
                          height: Dimen.buttonHeight,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Get.isDarkMode
                                ? kPrimaryDarkColor
                                : kPrimaryColor,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            'Tìm'.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () {
                        _handleSearch();
                        //xóa kết quả không phù hợp ra khỏi filter hoặc thêm kết quả phù hợp
                      },
                    ),
                    noResult
                        ? Container(
                            child: const Text(
                              'Chưa tình thấy ai phù hợp, bạn thử tùy chọn khác xem!',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w200),
                            ),
                          )
                        : Container()
                  ],
                ),
              );
            })
      ],
    ));
  }
}
