import 'package:flutter/material.dart';

class LocationListTile extends StatelessWidget {
  final VoidCallback onPressed;
  final String street;
  final String number;
  final String city;
  final String postalCode;

  const LocationListTile({
    super.key,
    required this.onPressed,
    this.street = '',
    this.number = '',
    this.city = '',
    this.postalCode = '',
  });

  @override
  Widget build(BuildContext context) {
    // Determine the title and subtitle based on the provided information
    String title = '';
    String? subtitle;

    // Handle different combinations of address components
    if (street.isNotEmpty) {
      title = '$street${number.isNotEmpty ? ', $number' : ''}';
      subtitle = (city.isNotEmpty || postalCode.isNotEmpty)
          ? '${city.isNotEmpty ? city : ''}${postalCode.isNotEmpty ? ' $postalCode' : ''}'
              .trim()
          : null;
    } else if (city.isNotEmpty) {
      title = city;
      subtitle = postalCode.isNotEmpty ? postalCode : null;
    } else if (postalCode.isNotEmpty) {
      title = postalCode;
    }

    // Only return the ListTile if there is content to display
    if (title.isEmpty && subtitle == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        ListTile(
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle) : null,
          onTap: onPressed,
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
