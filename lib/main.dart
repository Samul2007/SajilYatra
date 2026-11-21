import 'package:flutter/material.dart';
import 'view/authentication/language_select.dart';
// To preview the other screens, swap the `home:` line below:
// import 'view/authentication/role_select.dart';   -> RoleSelectScreen()
// import 'view/authentication/login_screen.dart';  -> LoginScreen()

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LanguageSelectScreen(),
    );
  }
}
