import 'package:flutter/material.dart';
import 'package:battleships/services/auth_service.dart';
import 'package:battleships/views/game_list_screen.dart';
import 'package:battleships/views/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      routes: {
        '/login': (context) => const LoginScreen(),
        '/game_list': (context) => const GameListScreen(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      title: 'Battleships',
      home: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? token;

  @override
  void initState() {
    getToken();
    super.initState();
  }

  void getToken() async {
    token = await AuthService().getToken();
  }

  @override
  Widget build(BuildContext context) {
    return token == null ? const LoginScreen() : const GameListScreen();
  }
}
