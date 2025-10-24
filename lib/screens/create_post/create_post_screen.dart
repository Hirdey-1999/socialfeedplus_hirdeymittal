import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialfeed/provider/auth/auth_provider.dart';
import 'package:socialfeed/utils/widgets/common_widgets.dart';

import '../../provider/post_management/post_management_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with TickerProviderStateMixin {
  FocusNode captionField = FocusNode();
  final TextEditingController _captionController = TextEditingController();

  late final AnimationController _attachRotationController;
  late final AnimationController _postSuccessController;

  // Keep last provider posting state to detect transitions
  bool _wasPosting = false;
  VoidCallback? _providerListener;
  // removed unused image URL controller
  @override
  void initState() {
    super.initState();
    // initialize animation controllers immediately
    _attachRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _postSuccessController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    // auto-reverse the success animation after a short delay
    _postSuccessController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) _postSuccessController.reverse();
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FocusScope.of(context).requestFocus(captionField);

      // Listen to provider to start/stop attach rotation and detect post completion
      final provider = Provider.of<PostManagementProvider>(
        context,
        listen: false,
      );
      _wasPosting = provider.isPosting;
      _providerListener = () {
        if (!mounted) return;
        final p = Provider.of<PostManagementProvider>(context, listen: false);

        // Attach icon rotation while loading
        if (p.imageAttachmentState == ImageAttachmentState.loading) {
          if (!_attachRotationController.isAnimating)
            _attachRotationController.repeat();
        } else {
          if (_attachRotationController.isAnimating)
            _attachRotationController.stop();
          _attachRotationController.reset();
        }

        // Detect post completion transition true -> false and show success animation
        if (_wasPosting && !p.isPosting) {
          // play success
          _postSuccessController.forward(from: 0.0);
          // optionally you can clear image here
          // p.clearImageAttachment();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Posted successfully')));
        }
        _wasPosting = p.isPosting;
      };
      provider.addListener(_providerListener!);
    });
  }

  @override
  void dispose() {
    captionField.dispose();
    _captionController.dispose();
    if (_providerListener != null) {
      final provider = Provider.of<PostManagementProvider>(
        context,
        listen: false,
      );
      provider.removeListener(_providerListener!);
    }
    _attachRotationController.dispose();
    _postSuccessController.dispose();
    super.dispose();
  }

  // Simple typing animation for generated caption
  Future<void> _typeGeneratedCaption(String text) async {
    _captionController.text = '';
    for (var i = 0; i < text.length; i++) {
      if (!mounted) return;
      _captionController.text = text.substring(0, i + 1);
      await Future.delayed(const Duration(milliseconds: 25));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostManagementProvider>(
      builder: (context, postManagementProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Create Post",
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.4),
            elevation: 0,
          ),
          // Wrap body in a Stack to show post success overlay
          body: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.12),
                            child: Text(
                              Provider.of<AuthProvider>(context, listen: false)
                                      .currentUser
                                      ?.username
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  'U',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Provider.of<AuthProvider>(
                                        context,
                                        listen: false,
                                      ).currentUser?.username ??
                                      'You',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Share something with your followers',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Animated container to pulse background while generating caption
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 420),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  color:
                                      postManagementProvider.isGeneratingCaption
                                      ? Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha: 0.06)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(6),
                                child: CommonWidgets.textField(
                                  context,
                                  controller: _captionController,
                                  hintText: "What's on your mind?",
                                  maxLines: 5,
                                  minLines: 3,
                                  focusNode: captionField,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 12,
                                  ),
                                  suffixIcon: RotationTransition(
                                    turns: _attachRotationController,
                                    child: IconButton(
                                      onPressed:
                                          postManagementProvider
                                                  .imageAttachmentState ==
                                              ImageAttachmentState.loading
                                          ? null
                                          : () => postManagementProvider
                                                .pickImageAttachment(),
                                      icon: Icon(
                                        Icons.attach_file_outlined,
                                        color: Theme.of(context).primaryColor,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Image preview
                              if (postManagementProvider.image != null)
                                Container(
                                  height: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey[200],
                                    image: DecorationImage(
                                      image: FileImage(
                                        File(
                                          postManagementProvider.image!.path,
                                        ),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              postManagementProvider
                                                  .clearImageAttachment();
                                            },
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 12),

                              // AI caption generator button (same gradient style)
                              GestureDetector(
                                onTap: () async {
                                  // call provider to generate caption
                                  final generated = await postManagementProvider
                                      .generateCaption(
                                        prompt: _captionController.text,
                                      );
                                  // type the generated caption for a nicer effect
                                  if (generated != null) {
                                    await _typeGeneratedCaption(generated);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.purple.shade600,
                                        Colors.blue.shade600,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // show loader if generating
                                      if (postManagementProvider
                                          .isGeneratingCaption)
                                        SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      else
                                        Icon(
                                          Icons.auto_awesome,
                                          color: Colors.white,
                                        ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          postManagementProvider
                                                  .isGeneratingCaption
                                              ? 'Generating caption…'
                                              : 'Generate caption with AI',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Success overlay: centered check with scale+fade
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: Center(
                    child: FadeTransition(
                      opacity: _postSuccessController,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.6, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _postSuccessController,
                            curve: Curves.elasticOut,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: Theme.of(context).primaryColor,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () =>
                        postManagementProvider.pickImageAttachment(),
                    icon: Icon(Icons.attach_file_outlined),
                    label: Text('Attach'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedScale(
                      scale: postManagementProvider.isPosting ? 0.98 : 1.0,
                      duration: const Duration(milliseconds: 180),
                      child: ElevatedButton.icon(
                        onPressed:
                            postManagementProvider.isPosting ||
                                _captionController.text.trim().isEmpty
                            ? null
                            : () {
                                final currentUser = Provider.of<AuthProvider>(
                                  context,
                                  listen: false,
                                ).currentUser!;
                                postManagementProvider.createPost(
                                  context,
                                  caption: _captionController.text,
                                  currentUser: currentUser,
                                );
                                // Optionally clear
                                _captionController.clear();
                                captionField.unfocus();
                              },
                        icon: postManagementProvider.isPosting
                            ? SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(Icons.send_rounded),
                        label: Text(
                          postManagementProvider.isPosting
                              ? 'Posting…'
                              : 'Post',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
