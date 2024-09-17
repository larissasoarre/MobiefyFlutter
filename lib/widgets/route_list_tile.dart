import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';

class RouteListTile extends StatelessWidget {
  final TravelMode? travelMode;
  final String time;
  final String timeInMinutes;
  final String distance;
  final bool? divider;

  const RouteListTile({
    super.key,
    required this.travelMode,
    required this.time,
    required this.distance,
    required this.timeInMinutes,
    this.divider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        travelMode == TravelMode.walking
                            ? Icons.directions_walk_rounded
                            : travelMode == TravelMode.driving
                                ? Icons.drive_eta_rounded
                                : Icons.pedal_bike_rounded,
                      ),
                      SizedBox(width: travelMode == TravelMode.walking ? 0 : 5),
                      Text(
                        timeInMinutes,
                        style: AppFonts.text.copyWith(height: 1, fontSize: 13),
                      )
                    ],
                  ),
                  Text(
                    time,
                    style: AppFonts.text.copyWith(fontWeight: FontWeight.w700),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Image(
                    image: AssetImage('lib/assets/images/network_status.png'),
                    width: 10,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Distância de $distance',
                    style: AppFonts.text.copyWith(height: 1, fontSize: 14),
                  )
                ],
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          height: divider! ? 1 : 0,
          decoration: const BoxDecoration(
            color: AppColors.brightShade,
          ),
        ),
      ],
    );
  }
}
