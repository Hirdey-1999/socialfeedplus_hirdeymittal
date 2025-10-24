import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialfeed/utils/widgets/common_widgets.dart';

import '../../provider/auth/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

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
        // elevation: 5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 160.0),
              child: Container(
                margin: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 20,
                  children: [
                    CommonWidgets.textField(
                      context,
                      controller: emailController,
                      hintText: "Enter Email",
                      labelText: "Email",
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Colors.grey,
                      ),
                    ),
                    CommonWidgets.textField(
                      context,
                      controller: passwordController,
                      hintText: "Enter Password",
                      labelText: "Password",
                      obscureText: true,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.grey,
                      ),
                    ),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (emailController.text.isEmpty ||
                                passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill all fields'),
                                  margin: EdgeInsets.all(16),
                                  behavior: SnackBarBehavior.floating,
                                  showCloseIcon: true,
                                ),
                              );
                              return;
                            }

                            if (emailController.text.isNotEmpty &&
                                !RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}',
                                ).hasMatch(emailController.text)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a valid email'),
                                  margin: EdgeInsets.all(16),
                                  behavior: SnackBarBehavior.floating,
                                  showCloseIcon: true,
                                ),
                              );
                              return;
                            } else {
                              FocusScope.of(context).unfocus();

                              authProvider.login(
                                emailController.text,
                                passwordController.text,
                              );
                            }
                            // if (kDebugMode) {
                            //   print(HiveManagement.isUserLoggedIn());
                            //   // HiveManagement.loginUser(
                            //   //   username: emailController.text,
                            //   //   password: passwordController.text,
                            //   // );
                            // }
                          },
                          child: Container(
                            height: 48,
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child:
                                (authProvider.loadingStatus ==
                                    AuthLoadingStatus.loading)
                                ? CommonWidgets.customLoader()
                                : Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
