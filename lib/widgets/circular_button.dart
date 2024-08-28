import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';

class CircularButton extends StatelessWidget {
  final IconData? icon;
  final VoidCallback onPressed;
  final String label;
  final Color btnColor;
  final Color iconColor;
  final Color textColor;

  const CircularButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label = '',
    this.btnColor = AppColors.primary,
    this.iconColor = AppColors.white,
    this.textColor = AppColors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: Wrap(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: btnColor,
                  padding: const EdgeInsets.all(15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onPressed,
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: AppFonts.inputLabel.copyWith(color: textColor),
        ),
      ],
    );
  }
}
