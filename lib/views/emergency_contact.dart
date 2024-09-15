import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/views/emergency_contact_form.dart';
import 'package:mobiefy_flutter/views/home.dart';
import 'package:mobiefy_flutter/views/user_data_success.dart';
import 'package:mobiefy_flutter/widgets/button.dart';

class EmergencyContact extends StatefulWidget {
  const EmergencyContact({super.key});

  @override
  State<EmergencyContact> createState() => _EmergencyContactState();
}

class _EmergencyContactState extends State<EmergencyContact> {
  Future<void> _attemptPop() async {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          margin: const EdgeInsets.only(top: 20.0),
          alignment: Alignment.bottomCenter,
          child: AppBar(
            backgroundColor: AppColors.white,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: _attemptPop,
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.white,
      body: const PageContent(),
    );
  }
}

class PageContent extends StatefulWidget {
  const PageContent({super.key});
  @override
  State<PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<PageContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(38.0, 10.0, 38.0, 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Image(
              image: AssetImage('lib/assets/images/contact.png'),
            ),
            const SizedBox(height: 35.0),
            Column(children: [
              Text(
                "Adicione Contato de Emergência",
                style: AppFonts.heading
                    .copyWith(color: AppColors.primary, fontSize: 49),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25.0),
              Text(
                "Para sua segurança, configure um contato de emergência. Assim, se você se sentir em perigo, poderá acionar o botão de emergência e uma ligação será feita para a pessoa escolhida — seja um amigo, familiar ou o número de emergência local.",
                textAlign: TextAlign.center,
                style: AppFonts.text.copyWith(color: AppColors.black),
              ),
            ]),
            const SizedBox(height: 35.0),
            Column(
              children: [
                CustomButton(
                  label: 'Configurar depois',
                  color: AppColors.brightShade,
                  textColor: AppColors.black,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );
                  },
                ),
                const SizedBox(height: 14.0),
                CustomButton(
                  label: 'Continuar',
                  color: AppColors.primary,
                  textColor: AppColors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EmergencyContactForm()),
                    );
                  },
                ),
                const SizedBox(height: 30.0),
              ],
            )
          ],
        ));
  }
}
