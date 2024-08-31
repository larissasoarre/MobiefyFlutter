import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/views/login_screen.dart';
import 'package:mobiefy_flutter/widgets/button.dart';

class DataConsentScreen extends StatefulWidget {
  const DataConsentScreen({super.key});

  @override
  State<DataConsentScreen> createState() => _DataConsentScreenState();
}

class _DataConsentScreenState extends State<DataConsentScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                  Navigator.of(context).pop(); // Go back to the previous screen
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
  bool _performanceAnalytics = false;

  Future<void> _handleAgreeToAll() async {
    setState(() {
      _performanceAnalytics = true;
    });

    if (!mounted) return;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
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
                title: const Text('Desemprenho & Análise'),
                trailing: Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: _performanceAnalytics,
                    onChanged: (bool newValue) {
                      setState(() {
                        _performanceAnalytics = newValue;
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
                onPressed: () {
                  setState(() {
                    _performanceAnalytics = true;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
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
