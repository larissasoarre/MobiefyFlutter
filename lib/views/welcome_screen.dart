import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/views/login_screen.dart';
import 'package:mobiefy_flutter/widgets/button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(38.0, 60.0, 38.0, 25.0),
        color: AppColors.primary,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Image(image: AssetImage('lib/assets/images/welcome.png')),
            Column(children: [
              Text(
                "Bem Vindo",
                style: AppFonts.heading.copyWith(color: AppColors.white),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "ao",
                    style: AppFonts.heading.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(width: 15.0),
                  Text(
                    "Mobiefy",
                    style:
                        AppFonts.heading.copyWith(color: AppColors.secondary),
                  )
                ],
              ),
              const SizedBox(height: 15.0),
              Text(
                "Desbloqueando viagens inteligentes com seu passaporte de mobilidade eficiente!",
                textAlign: TextAlign.center,
                style: AppFonts.text.copyWith(color: AppColors.white),
              ),
            ]),
            Column(
              children: [
                CustomButton(
                  label: 'Começar',
                  color: AppColors.secondary,
                  textColor: AppColors.primary,
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
                      "Já tem uma conta?",
                      textAlign: TextAlign.center,
                      style: AppFonts.text.copyWith(color: AppColors.white),
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
                            color: AppColors.white,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ));
  }
}
