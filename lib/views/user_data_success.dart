import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/views/home.dart';
import 'package:mobiefy_flutter/widgets/button.dart';

class UserDataSuccess extends StatelessWidget {
  const UserDataSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
        height: screenHeight,
        padding: const EdgeInsets.fromLTRB(38.0, 60.0, 38.0, 25.0),
        color: AppColors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(image: AssetImage('lib/assets/images/success.png')),
            const SizedBox(height: 50),
            Text(
              'Informações salvas com sucesso!',
              style: AppFonts.heading.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 70),
            CustomButton(
                label: 'Concluir',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                })
          ],
        ));
  }
}
