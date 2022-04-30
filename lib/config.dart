import 'package:shared_preferences/shared_preferences.dart';

import 'navigationService.dart';


class Config {

  static Config? _instance;
  factory Config() => _instance ??= Config._();
  Config._();

  final String _token = 'token';

  Future getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_token);
  }

  void setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_token, token);
  }

  void delToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_token);
  }

  void logout(){
    Config().delToken();
    NavigationService.instance.navigateUntil("login");
  }

}