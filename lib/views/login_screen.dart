import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/views/welcome_screen.dart';
import 'package:mobiefy_flutter/widgets/button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: PageContent(),
      ),
    );
  }
}

class PageContent extends StatelessWidget {
  const PageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(38.0, 60.0, 38.0, 25.0),
      color: AppColors.white,
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
                .copyWith(color: AppColors.primary, fontSize: 32),
          ),
          const SizedBox(height: 17.0),
          Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("E-mail", style: AppFonts.inputLabel),
                  TextField(
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.brightShade,
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(15))),
                  )
                ],
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
                  TextField(
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.brightShade,
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(20))),
                  ),
                  const SizedBox(height: 30.0)
                ],
              )
            ],
          ),
          Column(
            children: [
              CustomButton(
                label: 'Entrar',
                color: AppColors.primary,
                textColor: AppColors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
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
                            builder: (context) => const WelcomeScreen()),
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
