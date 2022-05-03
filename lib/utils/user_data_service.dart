import 'package:get_storage/get_storage.dart';
import 'package:luanvanflutter/models/user.dart';

class UserDataService {
  final _box = GetStorage();
  final _key = 'userData';

  void _saveDataToBox(Map<String, dynamic> userData) {
    _box.write(_key, userData);
  }

  UserData? _loadThemeFromBox() => UserData.fromJson(_box.read(_key));

  void saveUserData(UserData userData) {
    _saveDataToBox((UserData.toJson(userData)));
  }

  UserData? getUserData() => _loadThemeFromBox();
}
