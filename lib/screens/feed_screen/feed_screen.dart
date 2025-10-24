import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialfeed/provider/auth/auth_provider.dart';
import 'package:socialfeed/provider/post_management/post_management_provider.dart';
import 'package:socialfeed/utils/router/router.dart';
import 'package:socialfeed/utils/widgets/common_widgets.dart';

import '../../models/post/post_model.dart';
import '../../utils/functions/app_functions.dart';
import '../../utils/router/paths/path.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final posts = Provider.of<PostManagementProvider>(context, listen: false);
    auth.getCurrentUser();
    posts.getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SocialFeed +",
          style: TextStyle(
            fontSize: 36,
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.4),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logoutUser();
            },
            icon: Icon(
              Icons.logout_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 28,
            ),
          ),
        ],
        // elevation: 5,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          router.pushNamed(Paths.createPost.routeName);
        },
        icon: Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 30,
          fontWeight: FontWeight.w400,
        ),
        label: Text("Add Post", style: TextStyle(color: Colors.white)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.explore_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                SizedBox(width: 8),
                Text(
                  "Explore",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1.2,
                  ),
                ),
                const Spacer(),
                // Refresh button for convenience
                Consumer<PostManagementProvider>(
                  builder: (context, p, child) {
                    return IconButton(
                      onPressed: p.isLoadingPosts ? null : () => p.getPosts(),
                      icon: p.isLoadingPosts
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.refresh_rounded),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 12),
            Expanded(
              child: Consumer<PostManagementProvider>(
                builder: (context, postProvider, child) {
                  if (postProvider.isLoadingPosts) {
                    // show modern loading placeholders
                    return ListView.separated(
                      itemCount: 4,
                      separatorBuilder: (_, __) => SizedBox(height: 12),
                      itemBuilder: (context, index) => _loadingCard(context),
                    );
                  }

                  if (postProvider.posts.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: postProvider.getPosts,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 60),
                          Center(
                            child: Text(
                              'No posts yet. Create the first one!',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: postProvider.getPosts,
                    child: ListView.builder(
                      itemCount: postProvider.posts.length,
                      itemBuilder: (context, index) {
                        final post = postProvider.posts[index];
                        return postCard(post);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget postCard(PostModel post) {
    return Consumer<PostManagementProvider>(
      builder: (context, postProvider, child) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              post.authorName.isNotEmpty
                                  ? post.authorName[0].toUpperCase()
                                  : '',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.authorName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  AppFunctions.formatTimestamp(post.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      if (post.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Builder(
                            builder: (context) {
                              try {
                                final bytes = base64Decode(post.imageUrl);
                                return Image.memory(
                                  Uint8List.fromList(bytes),
                                  fit: BoxFit.cover,
                                  height: 180,
                                  width: double.infinity,
                                );
                              } catch (e) {
                                return Container(
                                  height: 180,
                                  color: Colors.grey.shade200,
                                  child: Center(child: Icon(Icons.error)),
                                );
                              }
                            },
                          ),
                        ),
                      SizedBox(height: 12),
                      Text(post.caption, style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        postProvider.likePost(
                          postId: post.id,
                          userId:
                              Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              ).currentUser?.id ??
                              '',
                        );
                      },

                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            (post.likes?.contains(
                                      Provider.of<AuthProvider>(
                                        context,
                                        listen: false,
                                      ).currentUser?.id,
                                    ) ??
                                    false)
                                ? Icon(Icons.thumb_up_alt, color: Colors.red)
                                : Icon(Icons.thumb_up_alt_outlined),
                            SizedBox(width: 4),
                            Text(
                              '${post.likes?.length ?? 0}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showCommentsSheet(post);
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Icon(Icons.comment_outlined),
                            SizedBox(width: 4),
                            Text(
                              '${post.comments?.length ?? 0}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showCommentsSheet(PostModel post) {
    TextEditingController _commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: 400,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Comments',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12),
                Expanded(
                  child: post.comments == null || post.comments!.isEmpty
                      ? Center(
                          child: Text(
                            'No comments yet. Be the first to comment!',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          itemCount: post.comments!.length,
                          itemBuilder: (context, index) {
                            final comment = post.comments![index];
                            return ListTile(
                              title: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    child: Text(
                                      post.authorName.isNotEmpty
                                          ? post.authorName[0].toUpperCase()
                                          : '',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post.authorName.isNotEmpty
                                            ? post.authorName
                                            : '',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      Text(
                                        comment,
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                CommonWidgets.textField(
                  context,
                  controller: _commentController,
                  hintText: 'Add a comment',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send_rounded),
                    onPressed: () {
                      if (_commentController.text.trim().isNotEmpty) {
                        Provider.of<PostManagementProvider>(
                          context,
                          listen: false,
                        ).addComment(
                          postId: post.id,
                          userId:
                              Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              ).currentUser?.id ??
                              '',
                          comment: _commentController.text.trim(),
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _loadingCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: Colors.grey.shade300, radius: 20),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 12,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(height: 6),
                    Container(
                      width: 80,
                      height: 10,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(height: 160, color: Colors.grey.shade200),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 12,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 6),
            Container(
              width: double.infinity,
              height: 12,
              color: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}
