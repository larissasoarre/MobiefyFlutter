import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/views/data_agreement_screen.dart';
import 'package:mobiefy_flutter/views/signup_screen.dart';
import 'package:mobiefy_flutter/widgets/button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataConsentScreen extends StatefulWidget {
  const DataConsentScreen({super.key});

  @override
  State<DataConsentScreen> createState() => _DataConsentScreenState();
}

class _DataConsentScreenState extends State<DataConsentScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: Container(
            margin: const EdgeInsets.only(top: 20.0),
            alignment: Alignment.bottomCenter,
            child: AppBar(
              backgroundColor: AppColors.white,
              title: Text(
                'Gerenciar Acesso',
                style: AppFonts.text.copyWith(fontWeight: FontWeight.w700),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DataAgreementScreen()),
                  );
                },
              ),
            ),
          ),
        ),
        backgroundColor: AppColors.white,
        body: const PageContent(),
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
  bool performanceAnalyticsAgreement = false;

  Future<void> _handleAgreeToAll() async {
    setState(() {
      performanceAnalyticsAgreement = true;
    });

    if (!mounted) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedSetup', true);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpScreen(
              performanceAnalyticsAgreement: performanceAnalyticsAgreement,
            ),
          ),
        );
      }
    });
  }

  void _onAgree() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedSetup', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpScreen(
          performanceAnalyticsAgreement: performanceAnalyticsAgreement,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(38.0, 30.0, 38.0, 0),
      color: AppColors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const Text(
                "Usamos cookies e outras tecnologias para acessar, armazenar e processar informações do seu dispositivo. Isso nos ajuda a oferecer nossos serviços e melhorar continuamente sua experiência com o nosso produto. Você pode gerenciar suas preferências ou aceitar todos os usos abaixo.",
                style: AppFonts.text,
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                title: const Text('Obrigatórios'),
                trailing: Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: true,
                    onChanged: (_) {},
                    activeTrackColor: AppColors.brightShade,
                    inactiveThumbColor: AppColors.white,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                title: const Text('Desempenho & Análise'),
                trailing: Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: performanceAnalyticsAgreement,
                    onChanged: (bool newValue) {
                      setState(() {
                        performanceAnalyticsAgreement = newValue;
                      });
                    },
                    inactiveTrackColor: AppColors.brightShade,
                    activeTrackColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              CustomButton(
                label: 'Concordar',
                color: AppColors.brightShade,
                textColor: AppColors.black,
                onPressed: _onAgree,
              ),
              const SizedBox(height: 14.0),
              CustomButton(
                label: 'Concordar com todos',
                color: AppColors.primary,
                textColor: AppColors.white,
                onPressed: _handleAgreeToAll,
              ),
              const SizedBox(height: 30.0),
            ],
          )
        ],
      ),
    );
  }
}
