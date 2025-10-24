import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialfeed/models/auth/user_model.dart';
import 'package:socialfeed/models/post/post_model.dart';
import 'package:socialfeed/models/quote/quote_model.dart';
import 'package:socialfeed/utils/hive/hive_management.dart';
import 'package:socialfeed/utils/network/api_call.dart';
import 'package:socialfeed/utils/network/end_points.dart';

enum ImageAttachmentState { initial, loading, loaded, error }

class PostManagementProvider extends ChangeNotifier {
  ImageAttachmentState _imageAttachmentState = ImageAttachmentState.initial;

  bool _isPosting = false;
  bool _isGeneratingCaption = false;
  bool _isLoadingPosts = false;

  bool get isPosting => _isPosting;
  bool get isGeneratingCaption => _isGeneratingCaption;
  bool get isLoadingPosts => _isLoadingPosts;

  ImageAttachmentState get imageAttachmentState => _imageAttachmentState;

  XFile? image;

  List<PostModel> posts = [];
  List<Quotes> quotes = [];

  Future<void> getAICaptions() async {}

  void setImageAttachmentState(ImageAttachmentState state) {
    _imageAttachmentState = state;
    notifyListeners();
  }

  void pickImageAttachment() async {
    setImageAttachmentState(ImageAttachmentState.loading);
    try {
      ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedImage != null) {
        image = pickedImage;
      }
      // On success
      setImageAttachmentState(ImageAttachmentState.loaded);
    } catch (e) {
      // On error
      setImageAttachmentState(ImageAttachmentState.error);
    }
  }

  Future<String?> generateCaption({String prompt = ''}) async {
    _isGeneratingCaption = true;
    notifyListeners();

    NetworkManager api = NetworkManager();
    var resp = await api.get(
      endpoint: EndPoints.getQuotes,
      data: {'limit': 100},
    );

    if (resp != null) {
      QuoteModel quote = QuoteModel.fromJson(resp);
      quotes = quote.quotes ?? [];
      final random = Random();
      if (quotes.isNotEmpty) {
        String generatedCaption =
            quotes[random.nextInt(quotes.length)].quote ?? '';
        _isGeneratingCaption = false;
        notifyListeners();
        return generatedCaption;
      }
    }

    _isGeneratingCaption = false;
    notifyListeners();
    return null;
  }

  void clearImageAttachment() {
    image = null;
    setImageAttachmentState(ImageAttachmentState.initial);
  }

  void createPost(
    BuildContext context, {
    required String caption,
    required UserModel currentUser,
  }) async {
    _isPosting = true;
    notifyListeners();

    try {
      Uint8List imageData = image != null
          ? await image!.readAsBytes()
          : Uint8List(0);
      final encodedImage = imageData.isNotEmpty ? base64Encode(imageData) : '';
      PostModel newPost = PostModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        caption: caption,
        imageUrl: encodedImage,
        createdAt: DateTime.now(),
        authorId: currentUser.id ?? '',
        authorName: currentUser.username ?? "",
      );

      await HiveManagement.createPost(
        postId: newPost.id,
        postData: newPost.toJson(),
      );
      // Refresh posts after creating a new one
      await getPosts();
    } finally {
      _isPosting = false;
      Navigator.pop(context);
      clearImageAttachment();
      notifyListeners();
    }
  }

  Future<bool> likePost({
    required String postId,
    required String userId,
  }) async {
    PostModel? post = posts.firstWhere((post) => post.id == postId);
    if (post.likes == null) {
      post.likes = [];
    }
    if (post.likes!.contains(userId)) {
      post.likes!.remove(userId);
    } else {
      post.likes!.add(userId);
    }
    await HiveManagement.updatePost(
      postId: postId,
      postData: post.toJson(),
    );
    notifyListeners();
    return true;
  }

  Future<void> addComment({
    required String postId,
    required String userId,
    required String comment,
  }) async {
    PostModel? post = posts.firstWhere((post) => post.id == postId);
    if (post.comments?.isEmpty ?? true) {
      post.comments = [];
    }
    post.comments!.add(comment);
    await HiveManagement.updatePost(
      postId: postId,
      postData: post.toJson(),
    );
    notifyListeners();
  }

  Future<void> getPosts() async {
    _isLoadingPosts = true;
    notifyListeners();
    posts = await HiveManagement.getAllPosts();
    _isLoadingPosts = false;
    notifyListeners();
  }
}
