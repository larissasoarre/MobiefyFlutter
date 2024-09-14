import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/views/user_data_form.dart';
import 'package:mobiefy_flutter/widgets/button.dart';

class UserData extends StatefulWidget {
  const UserData({super.key});

  @override
  State<UserData> createState() => _UserDataState();
}

class _UserDataState extends State<UserData> {
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
              image: AssetImage('lib/assets/images/user_data_form.png'),
            ),
            const SizedBox(height: 35.0),
            Column(children: [
              Text(
                "Configuração da Conta",
                style: AppFonts.heading
                    .copyWith(color: AppColors.primary, fontSize: 49),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25.0),
              Text(
                "Queremos conhecer você melhor para oferecer uma experiência ainda mais personalizada!",
                textAlign: TextAlign.center,
                style: AppFonts.text.copyWith(color: AppColors.black),
              ),
            ]),
            const SizedBox(height: 35.0),
            Column(
              children: [
                CustomButton(
                  label: 'Continuar',
                  color: AppColors.primary,
                  textColor: AppColors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UserDataForm()),
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
