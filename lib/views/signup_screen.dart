import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/services/auth_service.dart';
import 'package:mobiefy_flutter/views/login_screen.dart';
import 'package:mobiefy_flutter/views/signup_success_screen.dart';
import 'package:mobiefy_flutter/widgets/button.dart';

class SignUpScreen extends StatefulWidget {
  final bool performanceAnalyticsAgreement;

  const SignUpScreen({
    super.key,
    required this.performanceAnalyticsAgreement,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PageContent(
            performanceAnalyticsAgreement: widget.performanceAnalyticsAgreement,
          ),
        ),
      ),
    );
  }
}

class PageContent extends StatefulWidget {
  final bool performanceAnalyticsAgreement;

  const PageContent({
    super.key,
    required this.performanceAnalyticsAgreement,
  });

  @override
  State<PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<PageContent> {
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  List<String> _passwordErrors = [];
  String _confirmPasswordError = '';
  String _generalError = '';
  bool _isLoading = false;

  List<String> _validatePassword(String password) {
    List<String> errors = [];

    if (password.isEmpty) {
      errors.add('A senha não pode estar vazia.');
      return errors;
    }

    if (password.length < 8) {
      errors.add('A senha deve ter pelo menos 8 caracteres.');
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      errors.add('A senha deve conter pelo menos uma letra maiúscula.');
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      errors.add('A senha deve conter pelo menos uma letra minúscula.');
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      errors.add('A senha deve conter pelo menos um número.');
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      errors.add('A senha deve conter pelo menos um caractere especial.');
    }

    return errors;
  }

  Future<void> _handleSignup() async {
    List<String> passwordErrors = _validatePassword(_passwordController.text);

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _confirmPasswordError = 'As senhas informadas não coincidem.';
      });
      return;
    } else {
      setState(() {
        _confirmPasswordError = '';
      });
    }

    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      _generalError = 'Todos os campos são obrigatórios.';
      return; // Exit the function early to prevent signup
    }

    if (passwordErrors.isNotEmpty) {
      setState(() {
        _passwordErrors = passwordErrors;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool isSignupSuccessful = await AuthService().signup(
      email: _emailController.text,
      password: _passwordController.text,
      fullName: _nameController.text,
      performanceAnalyticsAgreement: widget.performanceAnalyticsAgreement,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (isSignupSuccessful) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignUpSuccessScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O cadastro falhou. Tente novamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.fromLTRB(38.0, 60.0, 38.0, 25.0),
      color: AppColors.white,
      height: _passwordErrors.isEmpty ? screenHeight : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 100,
            child: Image.asset(
              'lib/assets/images/create_account.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 50.0),
          Text(
            "Faça seu cadastro!",
            style: AppFonts.heading
                .copyWith(color: AppColors.primary, fontSize: 32),
          ),
          const SizedBox(height: 30.0),
          Form(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Nome Completo", style: AppFonts.inputLabel),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.brightShade,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),
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
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
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
                              borderRadius: BorderRadius.circular(20),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _hidePassword =
                                      !_hidePassword; // Toggle visibility
                                });
                              },
                            ),
                          ),
                        ),
                        if (_passwordErrors.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _passwordErrors
                                .map((error) => Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        error,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        const SizedBox(height: 30.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Confirmar Senha",
                                style: AppFonts.inputLabel),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _hideConfirmPassword,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.brightShade,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _hideConfirmPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: AppColors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _hideConfirmPassword =
                                          !_hideConfirmPassword; // Toggle visibility
                                    });
                                  },
                                ),
                              ),
                            ),
                            if (_confirmPasswordError.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  _confirmPasswordError,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            if (_generalError.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  _generalError,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 30.0),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              if (_isLoading)
                const CircularProgressIndicator(
                  color: AppColors.primary,
                ) // Loader
              else
                CustomButton(
                  label: 'Cadastrar',
                  color: AppColors.primary,
                  textColor: AppColors.white,
                  onPressed: _handleSignup,
                ),
              const SizedBox(height: 15.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Já tem uma conta?",
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
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      "Faça login",
                      textAlign: TextAlign.center,
                      style: AppFonts.text.copyWith(
                          color: AppColors.black, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
