import 'package:get_storage/get_storage.dart';
import 'package:luanvanflutter/models/user.dart';

class UserDataService {
  final _box = GetStorage();
  final _key = 'userData';

  void _saveDataToBox(UserData userData) {
    _box.write(_key, userData);
  }

  UserData? _loadThemeFromBox() => _box.read(_key);

  void saveUserData(UserData userData) {
    _saveDataToBox(userData);
  }

  UserData? getUserData() => _loadThemeFromBox();
}
