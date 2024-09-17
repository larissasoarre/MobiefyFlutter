import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:http/http.dart' as http;

class AppMap extends StatefulWidget {
  final LatLng endRoute;
  final TravelMode? travelMode;
  final Function(String time, String distance) onTravelInfoUpdated;
  final Function(
      String drivingTime,
      String drivingDistance,
      String walkingTime,
      String walkingDistance,
      String bicyclingTime,
      String bicyclingDistance) onMixedTravelInfoUpdated;

  const AppMap({
    super.key,
    required this.endRoute,
    this.travelMode,
    required this.onTravelInfoUpdated,
    required this.onMixedTravelInfoUpdated,
  });

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

  String? drivingTime;
  String? drivingDistance;
  String? walkingTime;
  String? walkingDistance;
  String? bicyclingTime;
  String? bicyclingDistance;

  String? travelTime;

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
    _listenToLocationChanges();
    getPolyPoints(); // Initial call to get polyline
    getTravelInfo();
  }

  @override
  void didUpdateWidget(covariant AppMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.endRoute != oldWidget.endRoute ||
        widget.travelMode != oldWidget.travelMode) {
      getPolyPoints(); // Fetch new polyline points if routes change
      getTravelInfo();
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

  // Future<void> getPolyPoints() async {
  //   try {
  //     PolylineResult polylineResult =
  //         await polylinePoints.getRouteBetweenCoordinates(
  //       googleApiKey: apiKey,
  //       request: PolylineRequest(
  //         origin: PointLatLng(
  //             initialPosition!.latitude, initialPosition!.longitude),
  //         destination:
  //             PointLatLng(widget.endRoute.latitude, widget.endRoute.longitude),
  //         mode: widget.travelMode!,
  //       ),
  //     );

  //     if (polylineResult.points.isNotEmpty) {
  //       setState(() {
  //         polylineCoordinates = polylineResult.points
  //             .map((point) => LatLng(point.latitude, point.longitude))
  //             .toList();
  //       });
  //     } else {
  //       if (kDebugMode) {
  //         print('No route found between the given coordinates.');
  //       }
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error getting polyline points: $e');
  //     }
  //   }
  // }

  Future<void> getPolyPoints() async {
    if (widget.travelMode == null) {
      // Mixed route: fetch polyline for multiple modes and pick the fastest
      await _fetchPolylineForMode('driving');
      await _fetchPolylineForMode('walking');
      await _fetchPolylineForMode('bicycling');
    } else {
      // Fetch polyline for the selected travel mode
      await _fetchPolylineForMode(widget.travelMode.toString().split('.').last);
    }
  }

  Future<void> _fetchPolylineForMode(String mode) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition!.latitude},${initialPosition!.longitude}&destination=${widget.endRoute.latitude},${widget.endRoute.longitude}&mode=$mode&key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final polylineResult =
              data['routes'][0]['overview_polyline']['points'];
          List<PointLatLng> points =
              polylinePoints.decodePolyline(polylineResult);

          setState(() {
            polylineCoordinates = points
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList();
          });
        } else {
          if (kDebugMode) {
            print('No route found for mode: $mode');
          }
        }
      } else {
        if (kDebugMode) {
          print(
              'Failed to fetch polyline data. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching polyline for mode: $mode. Error: $e');
      }
    }
  }

  Future<void> getTravelInfo() async {
    if (initialPosition == null) return;

    if (widget.travelMode == null) {
      // Mixed mode: Request travel info for multiple modes
      await _fetchTravelInfoForMode('driving');
      await _fetchTravelInfoForMode('walking');
      await _fetchTravelInfoForMode('bicycling');

      widget.onMixedTravelInfoUpdated(
        drivingTime ?? 'N/A',
        drivingDistance ?? 'N/A',
        walkingTime ?? 'N/A',
        walkingDistance ?? 'N/A',
        bicyclingTime ?? 'N/A',
        bicyclingDistance ?? 'N/A',
      );
    } else {
      // Normal mode: Request travel info for the specified mode
      await _fetchTravelInfoForMode(
          widget.travelMode.toString().split('.').last);
    }
  }

  Future<void> _fetchTravelInfoForMode(String mode) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition!.latitude},${initialPosition!.longitude}&destination=${widget.endRoute.latitude},${widget.endRoute.longitude}&mode=$mode&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final duration =
              formatDuration(data['routes'][0]['legs'][0]['duration']['text']);
          final distance = data['routes'][0]['legs'][0]['distance']['text'];

          setState(() {
            if (mode == 'driving') {
              drivingTime = duration;
              drivingDistance = distance;
            } else if (mode == 'walking') {
              walkingTime = duration;
              walkingDistance = distance;
            } else if (mode == 'bicycling') {
              bicyclingTime = duration;
              bicyclingDistance = distance;
            }
          });

          widget.onTravelInfoUpdated(
              duration, distance); // Still update the parent widget if needed
        } else {
          if (kDebugMode) {
            print('No routes found for mode: $mode');
          }
        }
      } else {
        if (kDebugMode) {
          print(
              'Failed to load directions for mode: $mode. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(
            'Error fetching travel time and distance for mode: $mode. Error: $e');
      }
    }
  }

  String formatDuration(String duration) {
    duration = duration.toLowerCase();

    if (duration.contains('hour') || duration.contains('hr')) {
      duration = duration.replaceAll('hours', 'hr').replaceAll('hour', 'hr');
    }

    if (duration.contains('min') || duration.contains('min')) {
      duration = duration.replaceAll('mins', 'min').replaceAll('minute', 'min');
    }

    return duration;
  }

  // Future<void> getTravelInfo() async {
  //   if (initialPosition == null) return;

  //   if (widget.travelMode == null) {
  //     // Mixed mode: Request travel info for multiple modes
  //     await _fetchTravelInfoForMode('driving');
  //     await _fetchTravelInfoForMode('walking');
  //     await _fetchTravelInfoForMode('transit');
  //   } else {
  //     // Normal mode: Request travel info for the specified mode
  //     await _fetchTravelInfoForMode(
  //         widget.travelMode.toString().split('.').last);
  //   }
  // }

  // Future<void> _fetchTravelInfoForMode(String mode) async {
  //   final String url =
  //       'https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition!.latitude},${initialPosition!.longitude}&destination=${widget.endRoute.latitude},${widget.endRoute.longitude}&mode=$mode&key=$apiKey';

  //   try {
  //     final response = await http.get(Uri.parse(url));

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);

  //       if (data['routes'] != null && data['routes'].isNotEmpty) {
  //         final duration = data['routes'][0]['legs'][0]['duration']['text'];
  //         final distance = data['routes'][0]['legs'][0]['distance']['text'];
  //         widget.onTravelInfoUpdated(
  //             duration, distance); // Notify parent of travel time and distance
  //       } else {
  //         if (kDebugMode) {
  //           print('No routes found for mode: $mode');
  //         }
  //       }
  //     } else {
  //       if (kDebugMode) {
  //         print(
  //             'Failed to load directions for mode: $mode. Status code: ${response.statusCode}');
  //       }
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print(
  //           'Error fetching travel time and distance for mode: $mode. Error: $e');
  //     }
  //   }
  // }

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
