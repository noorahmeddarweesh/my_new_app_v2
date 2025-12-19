import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../layout/main_layout.dart';
import '../services/auth_service.dart';
import '../services/firebase_messaging_service.dart';
import '../widgets/notification_panel.dart';
import '../providers/notification_provider.dart';
import 'package:provider/provider.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  String? firstName, lastName, email, password, confirmPassword;
  bool firstValid = true, lastValid = true, emailValid = true;
  bool passValid = true, confirmValid = true;
  bool hidePass = true, hideConfirm = true, loading = false;

  late FocusNode f1, f2, f3, f4, f5;

  @override
  void initState() {
    super.initState();
    f1 = FocusNode()..addListener(() => setState(() {}));
    f2 = FocusNode()..addListener(() => setState(() {}));
    f3 = FocusNode()..addListener(() => setState(() {}));
    f4 = FocusNode()..addListener(() => setState(() {}));
    f5 = FocusNode()..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    f1.dispose();
    f2.dispose();
    f3.dispose();
    f4.dispose();
    f5.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      final user = await _authService.signUpWithEmail(
        email: email!.trim(),
        password: password!,
        firstName: firstName!.trim(),
        lastName: lastName!.trim(),
      );

      if (user != null && mounted) {
  Provider.of<NotificationProvider>(context, listen: false)
      .startListening(user.uid);
  

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => MainLayout()),
  );
}
    } catch (e) {
      _showError("Signup failed. Try again.");
    } finally {
      setState(() => loading = false);
    }
  }
  Future<void> _facebookSignup() async {
  setState(() => loading = true);
  try {
    final user = await _authService.signInWithFacebook();
if (user != null && mounted) {

  Provider.of<NotificationProvider>(context, listen: false)
      .startListening(user.uid);

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => MainLayout()),
  );
}

  } catch (e) {
    _showError("Facebook sign up failed");
  } finally {
    setState(() => loading = false);
  }
}


  Future<void> _googleSignup() async {
    setState(() => loading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
 Provider.of<NotificationProvider>(context, listen: false)
      .startListening(user.uid);
  
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => MainLayout()),
  );
}
    } catch (e) {
      _showError("Google sign up failed");
    } finally {
      setState(() => loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Color _border(bool valid) => valid ? Colors.green : Colors.red;

  Widget _input({
    required IconData icon,
    required String hint,
    required FocusNode focus,
    required bool valid,
    bool obscure = false,
    Widget? suffix,
    required Function(String) onChanged,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: focus.hasFocus ? Colors.black : _border(valid),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        focusNode: focus,
        obscureText: obscure,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          suffixIcon: suffix,
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _social(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.1),
                blurRadius: 12),
          ],
        ),
        child: Center(child: FaIcon(icon, color: color, size: 28)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset("assets/aa/logo.png", height: 90),
              const SizedBox(height: 20),
              const Text("Create Account",
                  style:
                      TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              _input(
                icon: Icons.person,
                hint: "First Name",
                focus: f1,
                valid: firstValid,
                onChanged: (v) {
                  firstName = v;
                  firstValid = v.length >= 3;
                },
                validator: (v) => v!.length < 3 ? "" : null,
              ),
              const SizedBox(height: 15),

              _input(
                icon: Icons.person_outline,
                hint: "Last Name",
                focus: f2,
                valid: lastValid,
                onChanged: (v) {
                  lastName = v;
                  lastValid = v.length >= 3;
                },
                validator: (v) => v!.length < 3 ? "" : null,
              ),
              const SizedBox(height: 15),

              _input(
                icon: Icons.email,
                hint: "Email",
                focus: f3,
                valid: emailValid,
                onChanged: (v) {
                  email = v;
                  emailValid = v.contains("@");
                },
                validator: (v) => !v!.contains("@") ? "" : null,
              ),
              const SizedBox(height: 15),

              _input(
                icon: Icons.lock,
                hint: "Password",
                focus: f4,
                valid: passValid,
                obscure: hidePass,
                suffix: IconButton(
                  icon: Icon(hidePass ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => hidePass = !hidePass),
                ),
                onChanged: (v) {
                  password = v;
                  passValid = v.length >= 6;
                },
                validator: (v) => v!.length < 6 ? "" : null,
              ),
              const SizedBox(height: 15),

              _input(
                icon: Icons.lock_outline,
                hint: "Confirm Password",
                focus: f5,
                valid: confirmValid,
                obscure: hideConfirm,
                suffix: IconButton(
                  icon: Icon(hideConfirm ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => hideConfirm = !hideConfirm),
                ),
                onChanged: (v) {
                  confirmPassword = v;
                  confirmValid = v == password;
                },
                validator: (v) => v != password ? "" : null,
              ),
              const SizedBox(height: 25),

              GestureDetector(
                onTap: _signup,
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Sign up",
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("OR"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),

              Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    _social(FontAwesomeIcons.google, Colors.red, _googleSignup),
    const SizedBox(width: 20),
    _social(FontAwesomeIcons.facebookF, Colors.blue, _facebookSignup),
  ],
),

            ],
          ),
        ),
      ),
    );
  }
}
