import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../layout/main_layout.dart';
import '../services/auth_service.dart';
import '../providers/cart_provider.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../services/firebase_messaging_service.dart';
import '../providers/notification_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  String? email, password;
  bool isLoading = false;

  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  @override
  void dispose() {
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final user = await _authService.login(
        email: email!.trim(),
        password: password!,
      );

      if (user != null && mounted) {
        Provider.of<NotificationProvider>(context, listen: false)
            .startListening(user.uid);
        _goHome();
      }
    } on FirebaseAuthException catch (e) {
      _showError(_firebaseError(e.code));
    } catch (_) {
      _showError("Something went wrong. Try again.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => isLoading = true);

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null && mounted) {
        Provider.of<NotificationProvider>(context, listen: false)
            .startListening(user.uid);
        _goHome();
      }
    } catch (_) {
      _showError("Google sign-in failed");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _goHome() async {
    await Provider.of<CartProvider>(context, listen: false).fetchCart();
    await FirebaseMessagingService().init();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MainLayout()),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  String _firebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return "No account found for this email.";
      case 'wrong-password':
        return "Incorrect password.";
      case 'invalid-email':
        return "Invalid email format.";
      case 'too-many-requests':
        return "Too many attempts. Try again later.";
      default:
        return "Login failed.";
    }
  }

  Widget _socialIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.1),
              blurRadius: 12,
            ),
          ],
        ),
        child: Center(
          child: FaIcon(icon, color: color, size: 28),
        ),
      ),
    );
  }

  Widget _input({
    required IconData icon,
    required String hint,
    required Function(String) onChanged,
    required String? Function(String?) validator,
    bool obscure = false,
    FocusNode? focus,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.black),
      ),
      child: TextFormField(
        focusNode: focus,
        obscureText: obscure,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset("assets/aa/logo.png", height: 90),
                const SizedBox(height: 20),
                const Text(
                  "Welcome Back",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                _input(
                  icon: Icons.email,
                  hint: "Email",
                  focus: emailFocus,
                  onChanged: (v) => email = v,
                  validator: (v) => !v!.contains("@") ? "Invalid email" : null,
                ),
                const SizedBox(height: 15),
                _input(
                  icon: Icons.lock,
                  hint: "Password",
                  obscure: true,
                  focus: passwordFocus,
                  onChanged: (v) => password = v,
                  validator: (v) => v!.length < 6 ? "Min 6 characters" : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen()),
                    ),
                    child: const Text("Forgot password?"),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: isLoading ? null : _handleEmailLogin,
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Login",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Text("Or login with"),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialIcon(
                      FontAwesomeIcons.google,
                      Colors.red,
                      _handleGoogleLogin,
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  ),
                  child: const Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
