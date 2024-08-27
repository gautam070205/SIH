import 'package:attendance/Screens/homepage.dart';
import 'package:attendance/provider/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart'; // Ensure GetX is included in your pubspec.yaml

class UserRegisterPage extends ConsumerStatefulWidget {
  const UserRegisterPage({super.key});

  @override
  _UserRegisterPageState createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends ConsumerState<UserRegisterPage> {
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _pinController = TextEditingController();

  bool _isPinVisible = false; // Track if the PIN field should be visible

  void _registerUser() {
    final name = _nameController.text;
    final companyName = _companyController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final pin = _pinController.text;

    // Validate the inputs (e.g., password matching, valid email, etc.)
    if (password != confirmPassword) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    // Implement your registration logic here
    // For now, let's just print the user details
    print('Name: $name');
    print('Company: $companyName');
    print('Email: $email');
    print('Password: $password');
    print('Pin: $pin');

    // Call the registration method
    ref
        .read(authPageProvider.notifier)
        .signUp(name, email, password, companyName, confirmPassword);

    // Set the PIN field to be visible
    setState(() {
      _isPinVisible = true;
    });
  }

  void _verifyPin() async {
    final pin = _pinController.text;
    final email = _emailController.text;

    // Implement PIN verification logic here
    final pinVerified =
        await ref.read(authPageProvider.notifier).verifyPin(pin, email);

    if (pinVerified) {
      Get.to(() => Homepage()); // Redirect to HomePage
    } else {
      _showErrorDialog('Invalid PIN. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
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
        title: const Text('User Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Work Email',
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
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerUser, // Call the registration logic
                child: const Text('Register as User'),
              ),
              if (_isPinVisible) ...[
                const SizedBox(height: 20),
                TextField(
                  controller: _pinController,
                  decoration: const InputDecoration(
                    labelText: 'Enter PIN sent to email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _verifyPin, // Call the PIN verification logic
                  child: const Text('Verify PIN'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pinController.dispose();
    super.dispose();
  }
}
