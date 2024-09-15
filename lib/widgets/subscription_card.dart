import 'package:flutter/material.dart';

import 'package:mobiefy_flutter/constants/colors.dart';

import 'package:mobiefy_flutter/constants/fonts.dart';

enum SubscriptionType {
  free,

  paid,
}

class SubscriptionCard extends StatelessWidget {
  //  final bool currentSubscription;
//  final SubscriptionType type;
//  final String monthlyPrice;
//  final String annualPrice;
//  final Image cover;
//  final VoidCallback onPressed;
//  final Color color;
  const SubscriptionCard({
    super.key,

    // required this.currentSubscription,

    // required this.type,

    // required this.monthlyPrice,

    // required this.annualPrice,

    // required this.cover,

    // required this.color,

    // required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.secondaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: () {},
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.fromLTRB(9.0, 3.0, 9.0, 3.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              color: AppColors.primary,
                            ),
                            child: Text(
                              "Premium",
                              style: AppFonts.text.copyWith(
                                color: AppColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 13),
                          Text(
                            "Assinatura atual",
                            style: AppFonts.text.copyWith(
                              color: AppColors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "10",
                        style: AppFonts.heading.copyWith(
                          color: AppColors.primary,
                          fontSize: 40,
                        ),
                      ),
                      Text(
                        "Viagens",
                        style: AppFonts.text.copyWith(
                          color: AppColors.black,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 45),
                      Text(
                        "R\$19,99 / mês",
                        style: AppFonts.text.copyWith(
                          color: AppColors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Positioned(
              bottom: 0,
              right: 0,
              child: Image(
                image: AssetImage('lib/assets/images/free.png'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
