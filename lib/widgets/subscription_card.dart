import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';

enum SubscriptionType {
  free,
  paid,
}

class SubscriptionCard extends StatelessWidget {
  final bool currentSubscription;
  final SubscriptionType type;
  final bool? premiumStudent;
  final String? monthlyPrice;
  final String? annualPrice;
  final Image cover;
  final VoidCallback onPressed;
  final Color color;
  const SubscriptionCard({
    super.key,
    required this.currentSubscription,
    required this.type,
    this.premiumStudent = false,
    this.monthlyPrice,
    this.annualPrice,
    required this.cover,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    String? price = monthlyPrice ?? annualPrice;
    String? interval = monthlyPrice != null ? 'mês' : 'ano';
    String? trips = monthlyPrice != null ? '10' : '120';

    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: color,
            padding: const EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
          ),
          onPressed: onPressed,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
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
                                type == SubscriptionType.free
                                    ? "Grátis"
                                    : (premiumStudent == true)
                                        ? "Premium Estudante"
                                        : "Premium",
                                style: AppFonts.text.copyWith(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 13),
                            currentSubscription
                                ? Text(
                                    "Assinatura atual",
                                    style: AppFonts.text.copyWith(
                                      color: AppColors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                : const SizedBox()
                          ],
                        ),
                        const SizedBox(height: 20),
                        type == SubscriptionType.free
                            ? Text(
                                trips,
                                style: AppFonts.heading.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 40,
                                ),
                              )
                            : const Column(
                                children: [
                                  Image(
                                    image: AssetImage(
                                        'lib/assets/images/unlimited.png'),
                                    width: 60,
                                  ),
                                  SizedBox(height: 10)
                                ],
                              ),
                        Text(
                          type == SubscriptionType.free
                              ? "Viagens"
                              : "Viagens ilimitadas",
                          style: AppFonts.text.copyWith(
                            color: AppColors.black,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 45),
                        Text(
                          'R\$$price / $interval',
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
              Positioned(
                bottom: 0,
                right: 0,
                child: cover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
