import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_vm.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    // Restore status bar when leaving this screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    final success = await authViewModel.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Navigate to main navigation (home)
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      // Show error message
      final errorMessage = authViewModel.errorMessage ?? 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: const Color(0xFF5A3E2C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: 392,
                    height: 852,
                    child: Form(
                      key: _formKey,
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: const Color(0xFFA78971),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 92,
                              top: 0,
                              child: Container(
                                width: 210,
                                height: 263,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      "assets/images/coffeehand.png.png",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 128,
                              top: 250,
                              child: Container(
                                width: 130,
                                height: 88,
                                decoration: ShapeDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage(
                                      "assets/images/coffeebeans.png.png",
                                    ),
                                    fit: BoxFit.contain,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: 320,
                              child: Container(
                                width: 393,
                                height: 532,
                                decoration: const ShapeDecoration(
                                  color: Color(0xFFDCCFB9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(80),
                                      topRight: Radius.circular(80),
                                      bottomRight: Radius.circular(1),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 77,
                              top: 426,
                              child: _buildInputField(
                                "Email",
                                _emailController,
                                false,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            Positioned(
                              left: 77,
                              top: 523,
                              child: _buildInputField(
                                "Password",
                                _passwordController,
                                true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Positioned(
                              left: 130,
                              top: 347,
                              child: const SizedBox(
                                width: 133,
                                height: 52,
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 40,
                                    fontFamily: 'Abril Fatface',
                                    fontWeight: FontWeight.w400,
                                    height: 1.20,
                                    letterSpacing: -1.20,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 99,
                              top: 744,
                              child: GestureDetector(
                                onTap:
                                    authViewModel.isLoading
                                        ? null
                                        : _handleLogin,
                                child: Container(
                                  width: 196,
                                  padding: const EdgeInsets.all(12),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color:
                                        authViewModel.isLoading
                                            ? const Color(
                                              0xFF5A3E2C,
                                            ).withOpacity(0.6)
                                            : const Color(0xFF5A3E2C),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        width: 1,
                                        color: Color(0xFF2C2C2C),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Center(
                                    child:
                                        authViewModel.isLoading
                                            ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Color(0xFFF5F5F5)),
                                              ),
                                            )
                                            : const Text(
                                              'Login',
                                              style: TextStyle(
                                                color: Color(0xFFF5F5F5),
                                                fontSize: 16,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w400,
                                                height: 1,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            ),
                            // Sign up link
                            Positioned(
                              left: 77,
                              top: 800,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    SignUpScreen.routeName,
                                  );
                                },
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Color(0xFF1E1E1E),
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: "Don't have an account? ",
                                      ),
                                      TextSpan(
                                        text: 'Sign Up',
                                        style: const TextStyle(
                                          color: Color(0xFF5A3E2C),
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 137,
                              top: 255,
                              child: Container(
                                width: 104,
                                height: 50,
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                ),
                              ),
                            ),
                            // Top status bar
                            Positioned(
                              left: 0,
                              top: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 21,
                                  left: 16,
                                  right: 16,
                                  bottom: 19,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      '9:41',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 17,
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w600,
                                        height: 1.29,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Opacity(
                                          opacity: 0.35,
                                          child: Container(
                                            width: 25,
                                            height: 13,
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                side: const BorderSide(
                                                  width: 1,
                                                  color: Colors.black,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4.3),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 7),
                                        Container(
                                          width: 21,
                                          height: 9,
                                          decoration: ShapeDecoration(
                                            color: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(2.5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    bool isPassword, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 240,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1E1E1E),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.40,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 240,
          height: 40,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFD9D9D9)),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: TextFormField(
              controller: controller,
              obscureText: isPassword ? _obscurePassword : false,
              validator: validator,
              keyboardType: keyboardType,
              enabled: true,
              enableInteractiveSelection: true,
              style: const TextStyle(
                color: Color(0xFF1E1E1E),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: 'Enter ${label.toLowerCase()}',
                hintStyle: const TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 16,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: InputBorder.none,
                suffixIcon:
                    isPassword
                        ? IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF999999),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                        : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
