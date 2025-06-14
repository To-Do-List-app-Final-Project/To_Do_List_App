import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/core/utils/validators.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';

  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  // Get the AuthController instance
  final AuthController _authController = Get.find<AuthController>();

  void _attemptLogin() {
    if (_formKey.currentState!.validate()) {
      // Use the controller to handle login
      _authController.login(
        _emailController.text,
        _passwordController.text,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        // Listen for errors from controller
        if (_authController.error.isNotEmpty) {
          // Show error message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_authController.error.value)),
            );
            // Clear error after showing
            _authController.error.value = '';
          });
        }

        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                        child: Image.asset(
                      'assets/images/Tomorrowly_logo.png',
                      height: 150,
                      width: 400,
                    )),
                    const SizedBox(height: 15),
                    Text(
                      'Welcome back',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Login to continue using Tomorrowly',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.black54,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        hintText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: Color(0xFF26B6A5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: Color(0xFF26B6A5)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () =>
                              setState(() => _obscureText = !_obscureText),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _authController.isLoading.value
                          ? null
                          : _attemptLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF26B6A5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _authController.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Log in',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () => Get.toNamed('/signup'),
                          child: const Text('Sign up',
                              style: TextStyle(
                                  color: Color(0xFF26B6A5),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
