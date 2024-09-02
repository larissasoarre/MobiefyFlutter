import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobiefy_flutter/constants/colors.dart';

class AppMap extends StatefulWidget {
  const AppMap({super.key});

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? googleMapController;
  Position? userCurrentPosition;
  LatLng? initialPosition;

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  Future<void> _setInitialLocation() async {
    Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    setState(() {
      userCurrentPosition = userPosition;
      initialPosition = LatLng(userPosition.latitude, userPosition.longitude);
    });
  }

  Future<void> getCurrentLocation() async {
    Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    userCurrentPosition = userPosition;

    LatLng userLatLng = LatLng(userPosition.latitude, userPosition.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: userLatLng, zoom: 17);
    googleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: initialPosition == null
          ? const Center(
              child: CircularProgressIndicator(
              color: AppColors.primary,
            ))
          : GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: initialPosition!, zoom: 17),
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController mapController) {
                googleMapController = mapController;
                googleMapCompleterController.complete(googleMapController);
                getCurrentLocation();
              },
            ),
    );
  }
}
