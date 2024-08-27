import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/views/login_screen.dart';
import 'package:mobiefy_flutter/widgets/button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.fromLTRB(38.0, 60.0, 38.0, 25.0),
      color: AppColors.white,
      height: screenHeight,
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
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.brightShade,
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(20))),
                    ),
                    const SizedBox(height: 30.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("E-mail", style: AppFonts.inputLabel),
                        TextFormField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.brightShade,
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(15)),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 30.0),
                    Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Senha", style: AppFonts.inputLabel),
                            TextFormField(
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
                                    color: AppColors.primary,
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
                          ],
                        ),
                        const SizedBox(height: 30.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Confirmar Senha",
                                style: AppFonts.inputLabel),
                            TextFormField(
                              obscureText: _hideConfirmPassword,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.brightShade,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(20)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _hideConfirmPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: AppColors.primary,
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
                            const SizedBox(height: 30.0)
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              CustomButton(
                label: 'Cadastrar',
                color: AppColors.primary,
                textColor: AppColors.white,
                onPressed: () {},
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
          )
        ],
      ),
    );
  }
}
