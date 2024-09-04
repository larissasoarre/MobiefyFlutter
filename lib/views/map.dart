import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobiefy_flutter/constants/colors.dart';

class AppMap extends StatefulWidget {
  final LatLng endRoute;

  const AppMap({super.key, required this.endRoute});

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? googleMapController;
  Position? userCurrentPosition;
  LatLng? initialPosition;
  late StreamSubscription<Position> positionStream;

  String? apiKey = dotenv.env['GOOGLE_MAPS_API'];
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  BitmapDescriptor? customMarkerIcon;

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
    _listenToLocationChanges();
    getPolyPoints(); // Initial call to get polyline
  }

  @override
  void didUpdateWidget(covariant AppMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.endRoute != oldWidget.endRoute) {
      getPolyPoints(); // Fetch new polyline points if routes change
    }
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  Future<void> _setInitialLocation() async {
    try {
      Position userPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      setState(() {
        userCurrentPosition = userPosition;
        initialPosition = LatLng(userPosition.latitude, userPosition.longitude);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting initial location: $e');
      }
    }
  }

  void _listenToLocationChanges() {
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2, // meters
      ),
    ).listen((Position position) {
      setState(() {
        userCurrentPosition = position;
      });

      if (googleMapController != null) {
        googleMapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 17,
            ),
          ),
        );
      }
    });
  }

  Future<void> getCurrentLocation() async {
    try {
      Position userPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      userCurrentPosition = userPosition;

      LatLng userLatLng = LatLng(userPosition.latitude, userPosition.longitude);

      CameraPosition cameraPosition =
          CameraPosition(target: userLatLng, zoom: 17);
      googleMapController!
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current location: $e');
      }
    }
  }

  Future<void> getPolyPoints() async {
    try {
      PolylineResult polylineResult =
          await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: apiKey,
        request: PolylineRequest(
          origin: PointLatLng(
              initialPosition!.latitude, initialPosition!.longitude),
          destination:
              PointLatLng(widget.endRoute.latitude, widget.endRoute.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (polylineResult.points.isNotEmpty) {
        setState(() {
          polylineCoordinates = polylineResult.points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
        });
      } else {
        if (kDebugMode) {
          print('No route found between the given coordinates.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting polyline points: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: initialPosition == null
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: initialPosition!, zoom: 17),
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController mapController) {
                googleMapController = mapController;
                googleMapCompleterController.complete(googleMapController);
                getCurrentLocation();
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: polylineCoordinates,
                  color: AppColors.secondary,
                  width: 5,
                )
              },
              markers: {
                Marker(
                  markerId: const MarkerId("destination"),
                  position: widget.endRoute,
                ),
              },
            ),
    );
  }
}
