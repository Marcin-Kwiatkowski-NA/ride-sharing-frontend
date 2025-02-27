import 'package:blablafront/views/Search_Ride_Screen.dart';
import 'package:flutter/material.dart';

import 'Bottom_Buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String name = '';
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(child: _buildLoginForm()),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check, color: Colors.orangeAccent),
        Text('Hi $name'),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildLoginForm() {
    int screenNumber = 3;
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _nameController,
              autovalidateMode: AutovalidateMode.always,
              decoration: const InputDecoration(labelText: 'Runner'),
              validator:
                  (text) => text!.isEmpty ? 'Enter the runner\'s name.' : null,
            ),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              autovalidateMode: AutovalidateMode.always,
              validator: (text) {
                if (text!.isEmpty) {
                  return 'Enter the runner\'s email.';
                }
                final regex = RegExp('[^@]+@[^.]+..+');
                if (!regex.hasMatch(text)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _validate, child: const Text('Continue')),
            Spacer(),
            Bottom_Buttons(primary: screenNumber),
          ],
        ),
      ),
    );
  }

  void _validate() {
    final form = _formKey.currentState;
    if (form?.validate() == false) {
      return;
    }
    final name = _nameController.text;
    final email = _emailController.text;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SearchRideScreen()),
    );
  }
}
