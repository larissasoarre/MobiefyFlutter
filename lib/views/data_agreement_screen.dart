import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';

class DataAgreementScreen extends StatelessWidget {
  const DataAgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(38.0, 60.0, 38.0, 25.0),
        color: AppColors.primary,
        child: const Text("Data Agreement Screen"));
  }
}
