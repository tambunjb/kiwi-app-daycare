import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'config.dart';

class Api {

  static const String _baseUrl = 'https://api.kindercastle.co.id/';
  static const String _contentType = 'application/x-www-form-urlencoded; charset=UTF-8';

  static Future<Map<String, String>> _buildHeaders({bool token = true}) async {
    Map<String, String> headers = {
      'Content-Type': _contentType,
    };
    if(token){
      headers.addAll({'Authorization': 'Bearer ' + await Config().getToken()});
    }

    return headers;
  }

  static Future<dynamic> _processBody(dynamic body) async {
    body.updateAll((key, value) => value.toString());
    return body;
  }

  static Future<bool> login(String phone) async {
    final response = await http.post(
        Uri.parse(_baseUrl + 'login'),
        headers: await _buildHeaders(token: false),
        body: await _processBody({'phone': phone })
      );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      Config().setToken(body['token']);
      return true;
    } else {
      log(response.body);
    }

    return false;
  }

  static dynamic _processReturn(http.Response response){
    if (response.statusCode == 401) {
      Config().logout();
    } else if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body;
    } else {
      log(response.body);
    }

    return Future.value(false);
  }

  static Future<bool> addConfig({required String name, required String value, String desc = ''}) async {
    final response = await http.post(
        Uri.parse(_baseUrl + 'config/add'),
        headers: await _buildHeaders(),
        body: await _processBody({ 'name': name, 'value': value, 'desc': desc })
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return true;
    } else {
      log(response.body);
    }

    return false;
  }

  static Future<dynamic> getVersionUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    Map<String, String> queryParams = {
      'appid': 'kindercastleid',
      'version': packageInfo.buildNumber.toString()
    };

    final response = await http.get(
        Uri.parse(_baseUrl + 'config/get-version-update')
            .replace(queryParameters: queryParams),
        headers: await _buildHeaders()
    );

    return _processReturn(response);
  }

  static Future<dynamic> getMealConfigByLocation(String locationId, String dayOfMonth) async {
    final response = await http.get(
        Uri.parse(_baseUrl + 'meal-config/get-by-location/'+locationId+"/"+dayOfMonth),
        headers: await _buildHeaders()
    );

    return _processReturn(response);
  }

  static Future<dynamic> getReportRequiredFields() async {
    Map<String, String> queryParams = {
      'appid': 'kindercastleid'
    };

    final response = await http.get(
        Uri.parse(_baseUrl + 'config/get-report-required-fields')
            .replace(queryParameters: queryParams),
        headers: await _buildHeaders()
    );

    return _processReturn(response);
  }

  static Future<dynamic> getNanny() async {
    final response = await http.get(
      Uri.parse(_baseUrl + 'nanny/get-by-same-location'),
      headers: await _buildHeaders()
    );

    return _processReturn(response);
  }

  static Future<dynamic> getChild() async {
    final response = await http.get(
        Uri.parse(_baseUrl + 'child/get-by-same-location'),
        headers: await _buildHeaders()
    );

    return _processReturn(response);
  }

  static Future<dynamic> getReportByDate(String date) async {
    Map<String, String> queryParams = {
      'date': date
    };

    final response = await http.get(
        Uri.parse(_baseUrl + 'report/get-by-same-nanny-location')
            .replace(queryParameters: queryParams),
        headers: await _buildHeaders()
    );

    return _processReturn(response);
  }

  static Future<dynamic> addReport(Map<String, dynamic> report) async {
    final response = await http.post(
      Uri.parse(_baseUrl + 'report/add'),
      headers: await _buildHeaders(),
      body: await _processBody(report)
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['id'];
    } else {
      log(response.body);
    }

    return false;
  }

  static Future<bool> editReport(String id, Map<String, dynamic> report) async {
    final response = await http.post(
      Uri.parse(_baseUrl + 'report/edit/'+id),
      headers: await _buildHeaders(),
      body: await _processBody(report)
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return true;
    } else {
      log(response.body);
    }

    return false;
  }

  static Future<bool> setReportAbsent(String id) async {
    final response = await http.post(
        Uri.parse(_baseUrl + 'report/set-absent/'+id),
        headers: await _buildHeaders()
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return true;
    } else {
      log(response.body);
    }

    return false;
  }

  static Future<dynamic> addMilkSession(Map<String, dynamic> milkSession) async {
    final response = await http.post(
        Uri.parse(_baseUrl + 'milk-session/add'),
        headers: await _buildHeaders(),
        body: await _processBody(milkSession)
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['id'];
    } else {
      log(response.body);
    }

    return false;
  }

  static Future<bool> editMilkSession(String id, Map<String, dynamic> milkSession) async {
    final response = await http.post(
      Uri.parse(_baseUrl + 'milk-session/edit/'+id),
      headers: await _buildHeaders(),
      body: await _processBody(milkSession)
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return true;
    } else {
      log(response.body);
    }

    return false;
  }

  static Future<bool> delMilkSession(String id) async {
    final response = await http.post(
        Uri.parse(_baseUrl + 'milk-session/del/'+id),
        headers: await _buildHeaders()
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return true;
    } else {
      log(response.body);
    }

    return false;
  }

}