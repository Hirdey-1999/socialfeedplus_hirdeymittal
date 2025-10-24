import 'package:go_router/go_router.dart';
import 'package:socialfeed/screens/create_post/create_post_screen.dart';
import 'package:socialfeed/screens/feed_screen/feed_screen.dart';
import 'package:socialfeed/utils/hive/hive_management.dart';
import '../../screens/auth/login_screen.dart';
import 'paths/path.dart';

final GoRouter router = GoRouter(
  initialLocation: (HiveManagement.isUserLoggedIn())
      ? Paths.feed.pathName
      : Paths.login.pathName,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: Paths.login.pathName,
      name: Paths.login.routeName,
      builder: (context, state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: Paths.feed.pathName,
      name: Paths.feed.routeName,
      builder: (context, state) {
        return const FeedScreen();
      },
    ),
    GoRoute(
      path: Paths.createPost.pathName,
      name: Paths.createPost.routeName,
      builder: (context, state) {
        return const CreatePostScreen();
      },
    ),
  ],
);
