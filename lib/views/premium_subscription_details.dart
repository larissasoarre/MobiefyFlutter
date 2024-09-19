import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/services/url_launcher_service.dart';
import 'package:mobiefy_flutter/views/premium_student_subscription_details.dart';
import 'package:mobiefy_flutter/widgets/button.dart';
import 'package:mobiefy_flutter/widgets/subscription_card.dart';
import 'package:mobiefy_flutter/widgets/subscription_list_tile.dart';

class PremiumSubscriptionDetails extends StatelessWidget {
  final BillingCycle billingCycle;

  const PremiumSubscriptionDetails({super.key, required this.billingCycle});

  void _attemptPop(BuildContext context) {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          margin: const EdgeInsets.only(top: 30.0),
          alignment: Alignment.bottomCenter,
          child: AppBar(
            backgroundColor: AppColors.white,
            title: Text(
              'MobieClub',
              style: AppFonts.text.copyWith(fontWeight: FontWeight.w700),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => _attemptPop(context),
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.white,
      body: Container(
        padding: const EdgeInsets.fromLTRB(38.0, 38.0, 38.0, 30.0),
        child: PageContent(billingCycle: billingCycle),
      ),
    );
  }
}

class PageContent extends StatelessWidget {
  final BillingCycle billingCycle;

  const PageContent({
    super.key,
    required this.billingCycle,
  });

  @override
  Widget build(BuildContext context) {
    final monthlyPrice = billingCycle == BillingCycle.monthly ? '19,99' : null;
    final annualPrice = billingCycle == BillingCycle.annually ? '199,99' : null;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            SubscriptionCard(
              currentSubscription: false,
              type: SubscriptionType.paid,
              monthlyPrice: monthlyPrice,
              annualPrice: annualPrice,
              cover: const Image(
                image: AssetImage(
                  'lib/assets/images/premium.png',
                ),
                width: 240,
              ),
              color: AppColors.primaryLight,
              onPressed: () {},
            ),
            const Column(
              children: [
                SizedBox(height: 40),
                SubscriptionListTile(
                  label: 'Desfrute de viagens sem limites todos os meses',
                ),
                SizedBox(height: 20),
                SubscriptionListTile(
                  label:
                      'Acumule MobieCoins a cada trajeto e troque por viagens grátis',
                ),
                SizedBox(height: 20),
                SubscriptionListTile(
                  label:
                      'Aproveite ofertas e descontos especiais em serviços parceiros',
                ),
                SizedBox(height: 20),
                SubscriptionListTile(
                  label:
                      'Sua assinatura é renovada automaticamente a cada 30 dias. Cancele quando quiser, sem burocracia!',
                ),
              ],
            ),
          ],
        ),
        CustomButton(
          label: 'Aprenda mais sobre o MobieClub',
          color: AppColors.brightShade,
          textColor: AppColors.black,
          onPressed: () {
            launchUrlSite(url: 'https://mobiefy.netlify.app/mobieclub');
          },
        )
      ],
    );
  }
}
