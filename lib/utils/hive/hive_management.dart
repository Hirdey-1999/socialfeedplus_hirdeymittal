import 'dart:convert';
import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:socialfeed/models/auth/user_model.dart';
import 'package:socialfeed/models/post/post_model.dart';
import 'package:uuid/uuid.dart';

class HiveManagement {
  static String boxName = 'socialfeed_box';
  static String authBoxName = 'socialfeed_auth_box';

  static Box? _box;
  static Box? _authBox;

  Future<void> init() async {
    await Hive.initFlutter();

    _box = await Hive.openBox(boxName);

    _authBox = await Hive.openBox(authBoxName);
  }

  static Box get postsBox {
    if (_box == null) {
      throw Exception('Hive box is not initialized. Call init() first.');
    }
    return _box!;
  }

  static Box get authBox {
    if (_authBox == null) {
      throw Exception('Hive auth box is not initialized. Call init() first.');
    }
    return _authBox!;
  }

  static Future<bool> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      UserModel user = UserModel(
        id: Uuid().v4(),
        username: username,
        email: username,
      );
      await authBox.put(user.id, {
        'id': user.id,
        'username': user.username,
        'password': password,
      });
      // await authBox.put('username', user.username);
      // await authBox.put('password', password);
      return true;
    } catch (e) {
      log('Error logging in: $e');
      return false;
    }
  }

  static Future<List<PostModel>> getAllPosts() async {
    try {
      List<PostModel> posts = [];
      for (var key in postsBox.keys) {
        var postData = postsBox.get(key);
        posts.add(PostModel.fromJson(Map<String, dynamic>.from(postData)));
      }
      log('Retrieved ${posts.map((e) => e.toJson()).toList()} posts from Hive.');
      return posts;
    } catch (e) {
      log('Error retrieving posts: $e');
      return [];
    }
  }

  static Future createPost({
    required String postId,
    required Map<String, dynamic> postData,
  }) async {
    try {
      await postsBox.put(postId, postData);
    } catch (e) {
      log('Error creating post: $e');
    }
  }

  static Future<void> logoutUser() async {
    await authBox.clear();
  }

  static bool isUserLoggedIn() {
    return authBox.isNotEmpty;
  }

  static Future<UserModel?> getCurrentUser() async {
    final userData = authBox.keys.isNotEmpty ? authBox.get(authBox.keys.first) : null;
    if (userData == null) return null;

    log('Retrieved user data from Hive: $userData');

    try {
      Map<String, dynamic> userMap;

      if (userData is String) {
        final decoded = jsonDecode(userData);
        if (decoded is Map) {
          userMap = Map<String, dynamic>.from(decoded);
        } else {
          log('Decoded userData is not a Map: ${decoded.runtimeType}');
          return null;
        }
      } else if (userData is Map) {
        userMap = Map<String, dynamic>.from(userData);
      } else {
        log('Unsupported userData type from Hive: ${userData.runtimeType}');
        return null;
      }

      final currentUser = UserModel.fromJson(userMap);
      return currentUser;
    } catch (e) {
      log('Error parsing stored user data: $e');
      return null;
    }
  }

  static Future<void> closeBoxes() async {
    await postsBox.close();
    await authBox.close();
  }

  static Future<void> clearAllData() async {
    await postsBox.clear();
    await authBox.clear();
  }

  static Future updatePost({
    required String postId,
    required Map<String, dynamic> postData,
  }) async {
    try {
      await postsBox.put(postId, postData);
    } catch (e) {
      log('Error updating post: $e');
    }
  }
}
