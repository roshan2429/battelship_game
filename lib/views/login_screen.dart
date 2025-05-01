import 'package:battleships/views/game_list_screen.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool isLoading = false;

  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });
    final result = await _authService.login(
      _usernameController.text,
      _passwordController.text,
    );
    setState(() {
      isLoading = false;
    });

    if (result == 'Logged in successfully!') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GameListScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login Failed")));
    }
  }

  Future<void> _register() async {
    setState(() {
      isLoading = true;
    });
    final result = await _authService.register(
      _usernameController.text,
      _passwordController.text,
    );
    setState(() {
      isLoading = false;
    });

    if (result == 'Registered successfully!') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GameListScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Register Failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.cyan.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Battleship',
                  style: GoogleFonts.pirataOne(
                    fontSize: 48,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: GoogleFonts.roboto(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: GoogleFonts.roboto(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton('Login', _login),
                        _buildButton('Register', _register),
                      ],
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade900,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      child: Text(
        text,
        style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
