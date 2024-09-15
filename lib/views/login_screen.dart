import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/services/auth_service.dart';
import 'package:mobiefy_flutter/views/home.dart';
import 'package:mobiefy_flutter/views/signup_screen.dart';
import 'package:mobiefy_flutter/widgets/button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: PageContent()),
      ),
    );
  }
}

class PageContent extends StatefulWidget {
  const PageContent({super.key});

  @override
  State<PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<PageContent> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _hidePassword = true;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Todos os campos são obrigatórios.';
      });
      return;
    }

    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    bool isLoginSuccessful = await AuthService().signin(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _errorMessage = AuthService.signupError;
    });

    if (isLoginSuccessful) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.fromLTRB(38.0, 60.0, 38.0, 25.0),
      color: AppColors.white,
      height: _errorMessage.isEmpty ? screenHeight : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 155,
            child: Image.asset(
              'lib/assets/images/login.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 50.0),
          Text(
            "Bem-vindo de volta!",
            style: AppFonts.heading
                .copyWith(color: AppColors.primary, fontSize: 31),
          ),
          const SizedBox(height: 17.0),
          Form(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("E-mail", style: AppFonts.inputLabel),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.brightShade,
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(15))),
                    )
                  ],
                ),
                const SizedBox(height: 30.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Senha", style: AppFonts.inputLabel),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.brightShade,
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(20)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 30.0)
                  ],
                )
              ],
            ),
          ),
          Column(
            children: [
              if (_isLoading)
                const CircularProgressIndicator(
                  color: AppColors.primary,
                )
              else
                CustomButton(
                  label: 'Entrar',
                  color: AppColors.primary,
                  textColor: AppColors.white,
                  onPressed: _handleLogin,
                ),
              const SizedBox(height: 15.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Não tem uma conta?",
                    textAlign: TextAlign.center,
                    style: AppFonts.text.copyWith(
                        color: AppColors.black, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(width: 5.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpScreen(
                                  performanceAnalyticsAgreement: false,
                                )),
                      );
                    },
                    child: Text(
                      "Cadastre-se",
                      textAlign: TextAlign.center,
                      style: AppFonts.text.copyWith(
                          color: AppColors.black, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
