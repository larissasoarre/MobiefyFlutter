import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/views/data_agreement_screen.dart';
import 'package:mobiefy_flutter/views/permission_denied_screen.dart';
import 'package:mobiefy_flutter/widgets/button.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  Future<void> _checkLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      final result = await Permission.locationWhenInUse.request();
      if (result.isGranted) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const DataAgreementScreen()),
          );
        }
      } else if (result.isPermanentlyDenied) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const PermissionDeniedScreen()),
          );
        }
      }
    } else if (status.isGranted) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DataAgreementScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(38.0, 60.0, 38.0, 25.0),
      color: AppColors.primary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 10.0),
          const Image(image: AssetImage('lib/assets/images/location.png')),
          Column(
            children: [
              Text(
                "Permita o uso da sua localização",
                textAlign: TextAlign.center,
                style: AppFonts.heading.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 25.0),
              Text(
                "É a partir dela que te damos as melhores rotas e sugestões personalizadas para facilitar o seu trajeto.",
                textAlign: TextAlign.center,
                style: AppFonts.text.copyWith(color: AppColors.white),
              ),
            ],
          ),
          Column(
            children: [
              CustomButton(
                label: 'Concordar',
                color: AppColors.secondary,
                textColor: AppColors.primary,
                onPressed: _checkLocationPermission,
              ),
              const SizedBox(height: 30.0),
            ],
          )
        ],
      ),
    );
  }
}
