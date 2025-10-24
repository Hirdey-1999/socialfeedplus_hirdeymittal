import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/post_management/post_management_provider.dart';
import 'provider/auth/auth_provider.dart';
import 'utils/hive/hive_management.dart';
import 'utils/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveManagement().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostManagementProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router, title: 'SocialFeed +');
  }
}
