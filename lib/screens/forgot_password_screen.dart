import 'package:flutter/material.dart';
import 'reset_password_done_screen.dart';
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String? email;
  bool emailValid = true;

  late FocusNode emailFocus;

  @override
  void initState() {
    super.initState();
    emailFocus = FocusNode()..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    emailFocus.dispose();
    super.dispose();
  }

  Color borderColor() {
    if (emailFocus.hasFocus) return Colors.black;
    return emailValid ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),

              Image.asset("assets/aa/logo.png", height: 90),

              const SizedBox(height: 20),
              const Text(
                "Reset Password",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Enter your email and we will send you reset instructions",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // EMAIL FIELD
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: borderColor(),
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
                  focusNode: emailFocus,
                  onChanged: (val) {
                    email = val;
                    emailValid = val.contains("@") && val.contains(".");
                    setState(() {});
                  },
                  validator: (val) {
                    if (val!.isEmpty ||
                        !val.contains("@") ||
                        !val.contains(".")) {
                      emailValid = false;
                      return "";
                    }
                    emailValid = true;
                    return null;
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email, color: Colors.black),
                    hintText: "Email",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),

              if (!emailValid && !emailFocus.hasFocus)
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 6),
                  child: Text(
                    "Enter a valid email",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 30),

              _blackButton("Send Reset Link"),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blackButton(String text) {
    return GestureDetector(
      onTap: () {
  if (_formKey.currentState!.validate()) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResetPasswordDoneScreen()),
    );
  }
},

      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}