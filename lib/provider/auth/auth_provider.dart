

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:socialfeed/utils/router/router.dart';

import '../../models/auth/user_model.dart';
import '../../utils/hive/hive_management.dart';
import '../../utils/router/paths/path.dart';

enum AuthLoadingStatus { idle, loading, success, error }

class AuthProvider extends ChangeNotifier {
  AuthLoadingStatus loadingStatus = AuthLoadingStatus.idle;
  UserModel? currentUser;

  Future<void> getCurrentUser() async {
    final userData = await HiveManagement.getCurrentUser();
    if (userData != null) {
      log('Retrieved current user from Hive: ${userData.username}');
      currentUser = userData;
      notifyListeners();
    }
  }

  Future<void> logoutUser() async {
    await HiveManagement.logoutUser();
    currentUser = null;
    router.pushReplacementNamed(Paths.login.routeName);
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    loadingStatus = AuthLoadingStatus.loading;
    notifyListeners();

    try {
      // Simulate a login request
      await Future.delayed(Duration(seconds: 2));

      bool success = await HiveManagement.loginUser(
        username: email,
        password: password,
      );
      if (success) {
        loadingStatus = AuthLoadingStatus.success;
        router.pushReplacementNamed(Paths.feed.routeName);
      } else {
        loadingStatus = AuthLoadingStatus.error;
      }
      notifyListeners();
    } catch (e) {
      loadingStatus = AuthLoadingStatus.error;
    } finally {
      notifyListeners();
    }
  }
}
