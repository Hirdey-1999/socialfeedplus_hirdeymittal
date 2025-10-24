import 'package:socialfeed/utils/router/route_model/route_model.dart';

class Paths {
  static RouteModel login = RouteModel(
    pathName: '/login',
    routeName: 'LoginScreen',
  );
  static RouteModel feed = RouteModel(
    pathName: '/feed',
    routeName: 'FeedScreen',
  );
  static RouteModel createPost = RouteModel(
    pathName: '/create-post',
    routeName: 'CreatePostScreen',
  );
}
