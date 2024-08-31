import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/widgets/button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobiefy_flutter/views/data_agreement_screen.dart';

class PermissionDeniedScreen extends StatefulWidget {
  const PermissionDeniedScreen({super.key});

  @override
  State<PermissionDeniedScreen> createState() => _PermissionDeniedScreenState();
}

class _PermissionDeniedScreenState extends State<PermissionDeniedScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionStatus();
    }
  }

  Future<void> _checkPermissionStatus() async {
    // Check the location permission status
    final status = await Permission.locationWhenInUse.status;

    // Ensure that the widget is still mounted before navigating
    if (mounted) {
      if (status.isGranted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DataAgreementScreen()),
        );
      }
    }
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(38.0, 60.0, 38.0, 25.0),
      color: AppColors.primary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Image(
              image: AssetImage('lib/assets/images/permission_denied.png')),
          Column(
            children: [
              const SizedBox(height: 80.0),
              Text(
                "Poxa!",
                textAlign: TextAlign.center,
                style: AppFonts.heading.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 25.0),
              Text(
                "Infelizmente, a autorização a sua localização é necessária para fazer o app funcionar. Caso mude de ideia, ative a permissão nas configurações do seu dispositivo.",
                textAlign: TextAlign.center,
                style: AppFonts.text.copyWith(color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: 170.0),
          CustomButton(
            label: 'Ir para as configurações',
            color: AppColors.secondary,
            textColor: AppColors.primary,
            onPressed: _openAppSettings,
          ),
          const SizedBox(height: 30.0),
        ],
      ),
    );
  }
}
