import 'dart:async';
import 'dart:convert';

import 'package:benji_shop_app/models/my_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token = '';
  DateTime? _expiryDate;
  String _userId = '';
  Timer? _authTimer;
  // Auth(this._expiryDate, this._token, this._userId);

  bool get isAuth {
    return token != '';
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != '') {
      return _token;
    }
    return '';
  }

  String get userId {
    return _userId;
  }

  Future<void> _authSingUpLogin(
      String email, String password, var stateUrl) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/$stateUrl?key=AIzaSyBH4yE-E7W2oYkUfhFM10EyRaE_CsUx4R8');
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      debugPrint(json.decode(response.body));
      if (json.decode(response.body)['error'] != null) {
        throw MyHttpExecptions(json.decode(response.body)['error']['message']);
      }
      _token = json.decode(response.body)['idToken'];
      _userId = json.decode(response.body)['localId'];
      _expiryDate = DateTime.now().add(Duration(
          seconds: int.parse(json.decode(response.body)['expiresIn'])));
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiriyDate': _expiryDate!.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authSingUpLogin(email, password, 'accounts:signUp');
  }

  Future<void> login(String email, String password) async {
    return _authSingUpLogin(email, password, 'accounts:signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractUserData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(extractUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      debugPrint('no value found ');
      return false;
    }
    _token = extractUserData['token'];
    _userId = extractUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = '';
    _userId = '';
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToexpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    Timer(Duration(seconds: timeToexpiry), logout);
  }
}
