import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/views/data_consent_screen.dart';
import 'package:mobiefy_flutter/views/signup_screen.dart';
import 'package:mobiefy_flutter/widgets/button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataAgreementScreen extends StatefulWidget {
  const DataAgreementScreen({super.key});

  @override
  State<DataAgreementScreen> createState() => _DataAgreementScreenState();
}

class _DataAgreementScreenState extends State<DataAgreementScreen> {
  void _onAgree() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedSetup', true);

    if (!mounted) return;

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SignUpScreen(
            performanceAnalyticsAgreement: true,
          ),
        ));
  }

  void _manageAccess() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedSetup', true);

    if (!mounted) return;

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const DataConsentScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(38.0, 60.0, 38.0, 25.0),
      color: AppColors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Image(
              image: AssetImage('lib/assets/images/data_permission.png')),
          Column(children: [
            const SizedBox(height: 25.0),
            Text(
              "Seus dados",
              style: AppFonts.heading.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 25.0),
            SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Com sua permissão, coletamos suas informações para criar uma conta de forma segura para que você possa utilizar o app. Também usamos sua geolocalização para personalizar sua experiência e melhorar a navegação de A a B.",
                    style: AppFonts.text.copyWith(color: AppColors.black),
                  ),
                  const SizedBox(height: 25.0),
                  Text(
                    "Você pode revisar ou alterar suas preferências de dados a qualquer momento nas configurações do app. Sua privacidade é importante para nós, e seus dados são usados apenas para melhorar sua experiência no app.",
                    style: AppFonts.text.copyWith(color: AppColors.black),
                  ),
                  const SizedBox(height: 25.0),
                  Text(
                    "Algumas informações são essenciais para o funcionamento do serviço e não podem ser desativadas. Para mais detalhes, consulte nossos Termos de Uso.",
                    style: AppFonts.text.copyWith(color: AppColors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30.0),
          ]),
          Column(
            children: [
              CustomButton(
                label: 'Gerenciar Acesso',
                color: AppColors.brightShade,
                textColor: AppColors.black,
                onPressed: _manageAccess,
              ),
              const SizedBox(height: 14.0),
              CustomButton(
                label: 'Concordar',
                color: AppColors.primary,
                textColor: AppColors.white,
                onPressed: _onAgree,
              ),
              const SizedBox(height: 30.0),
            ],
          )
        ],
      ),
    );
  }
}
