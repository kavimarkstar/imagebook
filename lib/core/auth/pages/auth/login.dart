import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:imagebook/core/auth/exceptions/auth_exceptions.dart';
import 'package:imagebook/core/auth/pages/auth/forgot_password_page.dart';
import 'package:imagebook/core/auth/pages/auth/register.dart';
import 'package:imagebook/core/auth/services/auth_service.dart';
import 'package:imagebook/navigation/navigation.dart';
import 'package:imagebook/responsive/responsive.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  bool _isLoading = false;

  // Sign in with email and password
  Future<void> _signInWithEmailPassword() async {
    if (!_formKey.currentState!.validate()) {
      return; // Form validation failed, do not proceed
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Attempt to sign in with email and password
      await AuthService().signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Navigate to MainPage only if sign-in is successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavigationPage()),
      );
    } catch (e) {
      String errorMessage;

      if (e is FirebaseAuthException) {
        // Handle FirebaseAuthException separately
        errorMessage = mapFirebaseAuthExceptionCode(e.code);
      } else {
        // Handle any other exceptions
        errorMessage = 'An unexpected error occurred.';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Error signing in: $errorMessage'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          Theme.of(context).platform ==
              {TargetPlatform.android, TargetPlatform.iOS}
          ? AppBar(title: const Text('Login'))
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isMobile(context)
            ? loginFrombuild(context)
            : Center(
                child: Card(
                  child: SizedBox(
                    width: 400,
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: loginFrombuild(context),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget loginFrombuild(BuildContext context) {
    return Form(
      key: _formKey, // Assign the form key
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Login",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hint: Text("Email")),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 25),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(hint: Text("Password")),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordPage(),
                    ),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(120),
                ),
              ),
              onPressed: _signInWithEmailPassword,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ),

          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => RegisterPage()),
              );
            },
            child: const Text('Don\'t have an account? Register here'),
          ),
        ],
      ),
    );
  }
}
