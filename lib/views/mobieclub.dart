import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/services/firestore_service.dart';
import 'package:mobiefy_flutter/views/free_subscription_details.dart';
import 'package:mobiefy_flutter/views/premium_student_subscription_details.dart';
import 'package:mobiefy_flutter/views/premium_subscription_details.dart';
import 'package:mobiefy_flutter/widgets/button.dart';
import 'package:mobiefy_flutter/widgets/subscription_card.dart';

class MobieClub extends StatefulWidget {
  const MobieClub({super.key});

  @override
  State<MobieClub> createState() => _MobieClubState();
}

class _MobieClubState extends State<MobieClub> {
  late String _uid;
  final bool _isMonthly = true;

  Future<void> _attemptPop() async {
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
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
  bool _isMonthly = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(38.0, 0, 38.0, 0),
            child: Stack(
              children: [
                Row(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        setState(() {
                          _isMonthly = true;
                        });
                      },
                      child: const Text(
                        'Mensal',
                        style: AppFonts.text,
                      ),
                    ),
                    const SizedBox(width: 15),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isMonthly = false;
                        });
                      },
                      child: const Text(
                        'Anual',
                        style: AppFonts.text,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 7,
                  left: _isMonthly ? 0 : 82,
                  child: Container(
                    width: _isMonthly ? 58 : 46,
                    height: 2,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // _isMonthly ? const MonthlyContent() : const AnnualContent(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                // Define sliding direction based on the content
                final monthly = Tween<Offset>(
                  begin: _isMonthly
                      ? const Offset(-1.0, 0.0)
                      : const Offset(-1.0, 0.0),
                  end: _isMonthly
                      ? const Offset(0.0, 0.0)
                      : const Offset(0.0, 0.0),
                ).animate(animation);

                final annualy = Tween<Offset>(
                  begin: _isMonthly
                      ? const Offset(1.0, 0.0)
                      : const Offset(1.0, 0.0),
                  end: _isMonthly
                      ? const Offset(0.0, 0.0)
                      : const Offset(0.0, 0.0),
                ).animate(animation);

                // Apply the appropriate animation to the child widget
                return child.key == const ValueKey('monthly')
                    ? SlideTransition(position: monthly, child: child)
                    : SlideTransition(position: annualy, child: child);
              },
              child: _isMonthly
                  ? const MonthlyContent(key: ValueKey('monthly'))
                  : const AnnualContent(key: ValueKey('annual')),
            ),
          ),
        ],
      ),
    );
  }
}

// Example class for annual content
class AnnualContent extends StatelessWidget {
  const AnnualContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(38.0, 0, 38.0, 0),
      color: AppColors.white,
      child: Column(
        children: [
          const SizedBox(height: 15),
          SubscriptionCard(
            currentSubscription: true,
            type: SubscriptionType.free,
            premiumStudent: true,
            annualPrice: '00,00',
            cover: const Image(
              image: AssetImage(
                'lib/assets/images/free.png',
              ),
              width: 240,
            ),
            color: AppColors.secondaryLight,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FreeSubscriptionDetails(
                    billingCycle: BillingCycle.annually,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          SubscriptionCard(
            currentSubscription: false,
            type: SubscriptionType.paid,
            annualPrice: '199,99',
            cover: const Image(
              image: AssetImage(
                'lib/assets/images/premium.png',
              ),
              width: 240,
            ),
            color: AppColors.primaryLight,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PremiumSubscriptionDetails(
                    billingCycle: BillingCycle.annually,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          SubscriptionCard(
            currentSubscription: false,
            type: SubscriptionType.paid,
            annualPrice: '99,99',
            premiumStudent: true,
            cover: const Image(
              image: AssetImage(
                'lib/assets/images/premium_student.png',
              ),
              width: 240,
            ),
            color: AppColors.secondaryLight,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PremiumStudentSubscriptionDetails(
                    billingCycle: BillingCycle.annually,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MonthlyContent extends StatelessWidget {
  const MonthlyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(38.0, 0, 38.0, 0),
      color: AppColors.white,
      child: Column(
        children: [
          const SizedBox(height: 15),
          SubscriptionCard(
            currentSubscription: true,
            type: SubscriptionType.free,
            monthlyPrice: '00,00',
            annualPrice: '00,00',
            cover: const Image(
              image: AssetImage(
                'lib/assets/images/free.png',
              ),
              width: 240,
            ),
            color: AppColors.secondaryLight,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FreeSubscriptionDetails(
                      billingCycle: BillingCycle.monthly),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          SubscriptionCard(
            currentSubscription: false,
            type: SubscriptionType.paid,
            monthlyPrice: '19,99',
            cover: const Image(
              image: AssetImage(
                'lib/assets/images/premium.png',
              ),
              width: 240,
            ),
            color: AppColors.primaryLight,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PremiumSubscriptionDetails(
                      billingCycle: BillingCycle.monthly),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          SubscriptionCard(
            currentSubscription: false,
            type: SubscriptionType.paid,
            premiumStudent: true,
            monthlyPrice: '9,99',
            cover: const Image(
              image: AssetImage(
                'lib/assets/images/premium_student.png',
              ),
              width: 240,
            ),
            color: AppColors.secondaryLight,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PremiumStudentSubscriptionDetails(
                    billingCycle: BillingCycle.monthly,
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
