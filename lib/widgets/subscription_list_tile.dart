import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';

class SubscriptionListTile extends StatelessWidget {
  final String label;
  const SubscriptionListTile({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(Icons.check, size: 15.0),
          ),
          const SizedBox(width: 15.0),
          Expanded(
            child: Text(
              label,
              style: AppFonts.text,
            ),
          )
        ],
      ),
    );
  }
}
