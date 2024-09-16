import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'dart:math' as math;

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
    this.textColor = AppColors.white,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: onPressed,
        child: icon == null
            ? Text(
                label,
                style: AppFonts.text
                    .copyWith(fontWeight: FontWeight.w700, color: textColor),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon == Icons.navigation_rounded
                      ? Transform.rotate(
                          angle: math.pi / 4,
                          child: Icon(
                            icon,
                            color: textColor,
                            size: 18,
                          ),
                        )
                      : Icon(
                          icon,
                          color: textColor,
                        ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    label,
                    style: AppFonts.text.copyWith(
                        fontWeight: FontWeight.w700, color: textColor),
                  )
                ],
              ),
      ),
    );
  }
}
