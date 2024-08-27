import 'package:attendance/Screens/homepage.dart';
import 'package:attendance/Screens/registerScreens/adminregsiter.dart';
import 'package:attendance/Screens/registerScreens/company.dart';
import 'package:attendance/provider/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      // Use Riverpod to watch the loginProvider and call the login method
      await ref.read(authPageProvider.notifier).signIn(email, password);
      String token = ref.read(authPageProvider).token ?? '';
      if (token != null && token.isNotEmpty) {
        // Store the token securely

        // Optionally check token validity or handle different auth states
        // Navigate to Homepage if the token is valid
        Get.to(() => Homepage());
      } else {
        // Handle invalid login or token absence
        _showErrorDialog('Invalid login. Please try again.');
      }
    } catch (e) {
      // Handle errors (e.g., network issues, server errors)
      _showErrorDialog('An error occurred: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            // To avoid overflow on smaller screens
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Add Image
                Image.network(
                  'https://static.vecteezy.com/system/resources/previews/005/544/718/non_2x/profile-icon-design-free-vector.jpg',
                  height: 150,
                  width: 150,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, size: 150);
                  },
                ),
                const SizedBox(height: 20),

                const Text(
                  'XYZ',
                  style: TextStyle(fontSize: 24),
                ),

                const SizedBox(height: 20),

                // Login Form
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),

                const SizedBox(height: 20),

                // Registration Buttons
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminRegisterPage(),
                      ),
                    );
                  },
                  child: const Text('Register as Admin'),
                ),
                const SizedBox(height: 10),
                const Text(
                  'or',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserRegisterPage(),
                      ),
                    );
                  },
                  child: const Text('Register as User'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
