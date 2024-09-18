import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/services/firestore_service.dart';
import 'package:mobiefy_flutter/views/emergency_contact.dart';
import 'package:mobiefy_flutter/views/map.dart';
import 'package:mobiefy_flutter/widgets/app_drawer.dart';
import 'package:mobiefy_flutter/widgets/button.dart';
import 'package:mobiefy_flutter/widgets/circular_button.dart';
import 'package:mobiefy_flutter/widgets/location_list_tile.dart';
import 'package:mobiefy_flutter/widgets/route_list_tile.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<AppMapState> appMapKey = GlobalKey<AppMapState>();
  String _userName = '';
  final _searchController = TextEditingController();
  bool _isSearchFocused = false;
  bool _isPolylineDrawn = false;
  final FocusNode _searchFocusNode = FocusNode();
  var uuid = const Uuid();
  late String _uid;
  String _emergencyContactNumber = '';
  List<dynamic> listOfLocations = [];
  LatLng endRoute = const LatLng(0, 0);
  bool routeStarted = false;
  TravelMode? travelMode;
  String? travelTime;
  String? travelDistance;
  bool mixedRoute = true;

  String? drivingTime;
  String? drivingDistance;
  String? walkingTime;
  String? walkingDistance;
  String? bicyclingTime;
  String? bicyclingDistance;

  DateTime? _routeStartTime;
  DateTime? _routeEndTime;

  bool setWalkingRoute = false;
  bool setDrivingRoute = false;
  bool setBicyclingRoute = false;

  Widget results(bool mixedRoute, TravelMode? travelMode,
      String? travelDistance, String? travelTime) {
    // Convert travel times to minutes
    final drivingTimeInMinutes =
        drivingTime != null ? convertTimeToMinutes(drivingTime!) : 0;
    final walkingTimeInMinutes =
        walkingTime != null ? convertTimeToMinutes(walkingTime!) : 0;
    final bicyclingTimeInMinutes =
        bicyclingTime != null ? convertTimeToMinutes(bicyclingTime!) : 0;
    final selectedTimeInMinutes =
        travelTime != null ? convertTimeToMinutes(travelTime) : 0;

    if (mixedRoute) {
      // Display results for all travel modes if mixedRoute is true
      return Column(
        children: [
          RouteListTile(
            divider: true,
            travelMode: TravelMode.driving,
            distance: drivingDistance ?? 'N/A',
            time: drivingTime ?? '',
            timeInMinutes:
                drivingTime != null ? drivingTimeInMinutes.toString() : 'N/A',
            onPressed: () {
              setState(() {
                this.travelMode = TravelMode.driving;
                setDrivingRoute = true;
                setWalkingRoute = false;
                setBicyclingRoute = false;
              });
              _startRoute();
            },
          ),
          RouteListTile(
            divider: true,
            travelMode: TravelMode.walking,
            distance: walkingDistance ?? 'N/A',
            time: walkingTime ?? '',
            timeInMinutes:
                walkingTime != null ? walkingTimeInMinutes.toString() : 'N/A',
            onPressed: () {
              setState(() {
                this.travelMode = TravelMode.walking;
                setWalkingRoute = true;
                setDrivingRoute = false;
                setBicyclingRoute = false;
              });
              _startRoute();
            },
          ),
          RouteListTile(
            travelMode: TravelMode.bicycling,
            distance: bicyclingDistance ?? 'N/A',
            time: bicyclingTime ?? '',
            timeInMinutes: bicyclingTime != null
                ? bicyclingTimeInMinutes.toString()
                : 'N/A',
            onPressed: () {
              setState(() {
                this.travelMode = TravelMode.bicycling;
                setBicyclingRoute = true;
                setWalkingRoute = false;
                setDrivingRoute = false;
              });
              _startRoute();
            },
          ),
        ],
      );
    } else if (travelMode != null) {
      // Display only the selected travel mode
      return Column(
        children: [
          RouteListTile(
            travelMode: travelMode,
            distance: travelDistance ?? 'N/A',
            time: travelTime ?? '',
            timeInMinutes:
                travelTime != null ? selectedTimeInMinutes.toString() : 'N/A',
            onPressed: () {
              if (travelMode == TravelMode.walking) {
                setState(() {
                  setWalkingRoute = true;
                  setDrivingRoute = false;
                  setBicyclingRoute = false;
                });
                _startRoute();
              } else if (travelMode == TravelMode.driving) {
                setState(() {
                  setWalkingRoute = false;
                  setDrivingRoute = true;
                  setBicyclingRoute = false;
                });
                _startRoute();
              } else {
                setState(() {
                  setWalkingRoute = false;
                  setDrivingRoute = false;
                  setBicyclingRoute = true;
                });
                _startRoute();
              }
            },
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  int convertTimeToMinutes(String time) {
    // Initialize total minutes
    int totalMinutes = 0;

    // Remove any non-numeric characters
    final durationString =
        time.toLowerCase().replaceAll(RegExp(r'[^0-9\s]'), ' ').trim();
    final parts = durationString.split(RegExp(r'\s+'));

    if (parts.isNotEmpty) {
      // Parse hours and minutes if available
      if (parts.length == 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        totalMinutes = (hours * 60) + minutes;
      } else if (parts.length == 1) {
        final minutes = int.tryParse(parts[0]) ?? 0;
        totalMinutes = minutes;
      }
    }

    return totalMinutes;
  }

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (_uid.isNotEmpty) {
      _fetchUserData();
    }

    // Add a listener to the focus node to update the _isSearchFocused state
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
      _onChange();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  _onChange() {
    _locationSuggestion(_searchController.text);
  }

  // Fetch user data to get the current state of emergencyContactNumber
  Future<void> _fetchUserData() async {
    final userData = await FirestoreService().getUserDetails(_uid);

    if (mounted && userData != null) {
      setState(() {
        _emergencyContactNumber = userData['emergency_contact_number'] ?? '';
      });
    }
  }

  Future<void> _locationSuggestion(String input) async {
    String? apiKey = dotenv.env['GOOGLE_MAPS_API'];
    String sessionToken = uuid.v4();

    try {
      String baseUrl =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String requestUrl =
          '$baseUrl?input=$input&key=$apiKey&sessiontoken=$sessionToken';

      var response = await http.get(Uri.parse(requestUrl));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'OK') {
          setState(() {
            listOfLocations = data['predictions'];
          });
        } else {
          if (kDebugMode) {
            print('API Error: ${data['status']}');
          }
        }
      } else {
        if (kDebugMode) {
          print('Request failed with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
    }
  }

  Future<Map<String, dynamic>> _fetchPlaceDetails(String placeId) async {
    String? apiKey = dotenv.env['GOOGLE_MAPS_API'];
    String requestUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    try {
      var response = await http.get(Uri.parse(requestUrl));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'OK') {
          var result = data['result'];
          var addressComponents = result['address_components'] as List<dynamic>;

          String street = '';
          String number = '';
          String city = '';
          String postalCode = '';
          double latitude = result['geometry']['location']['lat'];
          double longitude = result['geometry']['location']['lng'];

          for (var component in addressComponents) {
            var types = component['types'] as List<dynamic>;
            var longName = component['long_name'] as String;

            if (types.contains('street_number')) {
              number = longName;
            } else if (types.contains('route')) {
              street = longName;
            } else if (types.contains('locality')) {
              city = longName;
            } else if (types.contains('postal_code')) {
              postalCode = longName;
            }
          }

          return {
            'street': street,
            'number': number,
            'city': city,
            'postalCode': postalCode,
            'latitude': latitude,
            'longitude': longitude,
          };
        } else {
          if (kDebugMode) {
            print('Details API Error: ${data['status']}');
          }
          return {};
        }
      } else {
        if (kDebugMode) {
          print('Request failed with status: ${response.statusCode}');
        }
        return {};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
      return {};
    }
  }

  String formatAddress(Map<String, dynamic> details) {
    String street = details['street'] ?? '';
    String number = details['number'] ?? '';
    String city = details['city'] ?? '';
    String postalCode = details['postalCode'] ?? '';

    List<String> addressParts = [];

    if (street.isNotEmpty || number.isNotEmpty) {
      addressParts.add('$street $number'.trim());
    }

    if (city.isNotEmpty) {
      addressParts.add(city);
    }

    if (postalCode.isNotEmpty) {
      addressParts.add(postalCode);
    }

    return addressParts.join(', ');
  }

  // Pre-load user's name before Drawer opens
  Future<void> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Map<String, dynamic>? userData =
          await FirestoreService().getUserDetails(user.uid);
      setState(() {
        _userName = userData?['full_name'] ?? 'Guest';
      });
    }
  }

  Future<void> _refreshUserName() async {
    await _fetchUserName();
  }

  void _startRoute() {
    setState(() {
      _routeStartTime = DateTime.now();
      if (travelTime != null) {
        final duration = _parseTravelTime(travelTime!);
        _routeEndTime = _routeStartTime?.add(duration);
      }
    });
  }

  Duration _parseTravelTime(String travelTime) {
    final regex = RegExp(r'(\d+) hour[s]?|(\d+) hr[s]?|(\d+) min|(\d+) mins?');
    final matches = regex.allMatches(travelTime.toLowerCase());

    int hours = 0, minutes = 0;

    for (final match in matches) {
      if (match.group(1) != null) hours = int.parse(match.group(1)!);
      if (match.group(2) != null) hours = int.parse(match.group(2)!);
      if (match.group(3) != null) minutes = int.parse(match.group(3)!);
      if (match.group(4) != null) minutes = int.parse(match.group(4)!);
    }

    return Duration(hours: hours, minutes: minutes);
  }

  Widget _buildRouteTimes() {
    String type = travelMode == TravelMode.walking
        ? 'Ande'
        : travelMode == TravelMode.driving
            ? 'Dirija'
            : 'Pedale';

    String? chosenTravelTime = travelMode == TravelMode.walking
        ? walkingTime
        : travelMode == TravelMode.driving
            ? drivingTime
            : bicyclingTime;

    return Container(
      padding: const EdgeInsets.only(left: 38, right: 38),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              Column(
                children: [
                  const SizedBox(height: 30),
                  const Image(
                    width: 18,
                    image: AssetImage(
                      'lib/assets/images/location_pin.png',
                    ),
                  ),
                  // Icon(Icons.location_pin),
                  const SizedBox(height: 10),
                  const Image(
                    image: AssetImage('lib/assets/images/dots.png'),
                  ),
                  const SizedBox(height: 10),
                  Icon(
                    travelMode == TravelMode.walking
                        ? Icons.directions_walk_rounded
                        : travelMode == TravelMode.driving
                            ? Icons.drive_eta_rounded
                            : Icons.pedal_bike_rounded,
                  ),
                  const SizedBox(height: 10),
                  const Image(
                    image: AssetImage(
                      'lib/assets/images/dots.png',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1), // Shadow color
                          spreadRadius: 1, // Spread radius
                          blurRadius: 10, // Blur radius
                        ),
                      ],
                      shape: BoxShape.rectangle,
                    ),
                    child: const Image(
                      image: AssetImage('lib/assets/images/end_location.png'),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            'Sua localização',
                            style: AppFonts.text
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          '${_routeStartTime!.toLocal().hour.toString().padLeft(2, '0')}:${_routeStartTime!.toLocal().minute.toString().padLeft(2, '0')}',
                          style: AppFonts.text
                              .copyWith(fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    const SizedBox(height: 52),
                    Row(
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              '$type por $chosenTravelTime',
                              style: AppFonts.text,
                            )),
                      ],
                    ),
                    const SizedBox(height: 52),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            _searchController.text,
                            style: AppFonts.text
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          '${_routeEndTime!.toLocal().hour.toString().padLeft(2, '0')}:${_routeEndTime!.toLocal().minute.toString().padLeft(2, '0')}',
                          style: AppFonts.text
                              .copyWith(fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 110),
          CustomButton(
              label: 'Atualizar',
              onPressed: () {
                _startRoute();
              })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GestureDetector(
        onTap: () {
          // Unfocus the search field when tapping outside of it
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          key: _scaffoldKey,
          drawer: AppDrawer(
            scaffoldKey: _scaffoldKey,
            userName: _userName,
            onUserNameUpdated: _refreshUserName,
          ),
          body: Stack(
            children: [
              AppMap(
                key: appMapKey,
                endRoute: endRoute,
                travelMode: travelMode,
                onTravelInfoUpdated: (String time, String distance) {
                  setState(() {
                    travelTime = time;
                    travelDistance = distance;
                  });
                },
                onMixedTravelInfoUpdated: (String drivingTime,
                    String drivingDistance,
                    String walkingTime,
                    String walkingDistance,
                    String bicyclingTime,
                    String bicyclingDistance) {
                  setState(() {
                    this.drivingTime = drivingTime;
                    this.drivingDistance = drivingDistance;
                    this.walkingTime = walkingTime;
                    this.walkingDistance = walkingDistance;
                    this.bicyclingTime = bicyclingTime;
                    this.bicyclingDistance = bicyclingDistance;
                  });
                },
                onStartRoute: _startRoute,
              ),
              Positioned(
                top: 40,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.primary),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    padding: const EdgeInsets.all(10),
                    iconSize: 24, // Size of the icon
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.warning_amber_rounded,
                        color: AppColors.primary),
                    onPressed: () {
                      _emergencyContactNumber.isEmpty
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EmergencyContact(),
                              ),
                            )
                          : showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppColors.white,
                                title: Text(
                                  'Emergência',
                                  textAlign: TextAlign.center,
                                  style: AppFonts.text
                                      .copyWith(fontWeight: FontWeight.w700),
                                ),
                                content: const Text(
                                  'Você clicou no botão de emergência. Ao escolher ligar para o 190, sua localização e dados serão compartilhados com as autoridades. Para quem deseja ligar?',
                                  style: AppFonts.text,
                                  textAlign: TextAlign.center,
                                ),
                                actions: [
                                  CustomButton(
                                    color: AppColors.secondary,
                                    textColor: AppColors.white,
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    label: '190',
                                  ),
                                  const SizedBox(height: 10),
                                  CustomButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    label: 'Contato de Emergência',
                                  ),
                                ],
                              ),
                            );
                    },
                    padding: const EdgeInsets.all(10),
                    iconSize: 24, // Size of the icon
                  ),
                ),
              ),
              DraggableScrollableSheet(
                initialChildSize: _isSearchFocused ? 0.79 : 0.13,
                maxChildSize: _isSearchFocused
                    ? 0.79
                    : _isPolylineDrawn
                        ? 0.6
                        : 0.3,
                minChildSize: 0.125,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: Stack(
                      children: [
                        ListView(
                          controller: scrollController,
                          children: [
                            // GestureDetector(
                            //     onVerticalDragUpdate: (details) {
                            //       // This allows dragging of the draggable sheet
                            //       scrollController.jumpTo(
                            //           scrollController.position.pixels -
                            //               details.primaryDelta!);
                            //     },
                            //     child: Positioned(
                            //       child: Center(
                            //         child: Container(
                            //           decoration: BoxDecoration(
                            //             color: Theme.of(context).hintColor,
                            //             borderRadius: const BorderRadius.all(
                            //                 Radius.circular(10)),
                            //           ),
                            //           height: 4,
                            //           width: 40,
                            //           margin: const EdgeInsets.symmetric(
                            //               vertical: 10),
                            //         ),
                            //       ),
                            //     )),
                            const SizedBox(height: 85),
                            _isSearchFocused
                                ? Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(23, 5, 23, 0),
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: listOfLocations.length,
                                      separatorBuilder: (context, index) =>
                                          const Divider(
                                        color: AppColors.brightShade,
                                        height: 0,
                                      ),
                                      itemBuilder: (context, index) {
                                        var location = listOfLocations[index];
                                        var description =
                                            location["description"] ?? '';
                                        var placeId =
                                            location["place_id"] ?? '';

                                        return FutureBuilder<
                                            Map<String, dynamic>>(
                                          future: _fetchPlaceDetails(placeId),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) {
                                              return const ListTile(
                                                  title: Text('Error'));
                                            } else {
                                              var details = snapshot.data ?? {};
                                              return LocationListTile(
                                                street: details['street'] ??
                                                    description,
                                                number: details['number'] ?? '',
                                                city: details['city'] ?? '',
                                                postalCode:
                                                    details['postalCode'] ?? '',
                                                onPressed: () async {
                                                  var placeId =
                                                      location["place_id"] ??
                                                          '';
                                                  var details =
                                                      await _fetchPlaceDetails(
                                                          placeId);
                                                  if (details.isNotEmpty) {
                                                    double? latitude =
                                                        details['latitude'];
                                                    double? longitude =
                                                        details['longitude'];
                                                    if (latitude != null &&
                                                        longitude != null) {
                                                      endRoute = LatLng(
                                                          latitude, longitude);
                                                      setState(() {
                                                        // Update the TextFormField with the formatted address
                                                        _searchController.text =
                                                            formatAddress(
                                                                details);
                                                        _isPolylineDrawn = true;
                                                        _isSearchFocused =
                                                            false; // Lose focus
                                                      });
                                                      if (mounted) {
                                                        FocusScope.of(context)
                                                            .unfocus();
                                                      }
                                                    } else {
                                                      if (kDebugMode) {
                                                        print(
                                                            'Error: Latitude or Longitude is null');
                                                      }
                                                    }
                                                  } else {
                                                    if (kDebugMode) {
                                                      print(
                                                          'Error: Details are empty');
                                                    }
                                                  }
                                                },
                                              );
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  )
                                : _isPolylineDrawn &&
                                        !setWalkingRoute &&
                                        !setBicyclingRoute &&
                                        !setDrivingRoute
                                    ? Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            23, 0, 23, 0),
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    IconButton(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStateProperty.all<
                                                                    Color>(
                                                                mixedRoute
                                                                    ? AppColors
                                                                        .secondary
                                                                    : AppColors
                                                                        .primary),
                                                        shape: WidgetStateProperty
                                                            .all<
                                                                OutlinedBorder>(
                                                          const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  13),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      iconSize: 25,
                                                      color: AppColors.white,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20),
                                                      onPressed: () {
                                                        setState(() {
                                                          travelMode = null;
                                                          mixedRoute = true;
                                                        });
                                                      },
                                                      icon: const Icon(
                                                          Icons.shuffle),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    const Text(
                                                      "Misto",
                                                      style: AppFonts.text,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  width: 25,
                                                ),
                                                Column(
                                                  children: [
                                                    IconButton(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStateProperty.all<
                                                                Color>(travelMode ==
                                                                    TravelMode
                                                                        .walking
                                                                ? AppColors
                                                                    .secondary
                                                                : AppColors
                                                                    .primary),
                                                        shape: WidgetStateProperty
                                                            .all<
                                                                OutlinedBorder>(
                                                          const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  13),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      iconSize: 25,
                                                      color: AppColors.white,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20),
                                                      onPressed: () {
                                                        setState(() {
                                                          travelMode =
                                                              TravelMode
                                                                  .walking;
                                                          mixedRoute = false;
                                                        });
                                                      },
                                                      icon: const Icon(Icons
                                                          .directions_walk_rounded),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    const Text(
                                                      "Andar",
                                                      style: AppFonts.text,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  width: 25,
                                                ),
                                                Column(
                                                  children: [
                                                    IconButton(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStateProperty.all<
                                                                Color>(travelMode ==
                                                                    TravelMode
                                                                        .driving
                                                                ? AppColors
                                                                    .secondary
                                                                : AppColors
                                                                    .primary),
                                                        shape: WidgetStateProperty
                                                            .all<
                                                                OutlinedBorder>(
                                                          const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  13),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      iconSize: 25,
                                                      color: AppColors.white,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20),
                                                      onPressed: () {
                                                        setState(() {
                                                          travelMode =
                                                              TravelMode
                                                                  .driving;
                                                          mixedRoute = false;
                                                        });
                                                      },
                                                      icon: const Icon(Icons
                                                          .drive_eta_rounded),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    const Text(
                                                      "Dirigir",
                                                      style: AppFonts.text,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  width: 25,
                                                ),
                                                Column(
                                                  children: [
                                                    IconButton(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStateProperty.all<
                                                                Color>(travelMode ==
                                                                    TravelMode
                                                                        .bicycling
                                                                ? AppColors
                                                                    .secondary
                                                                : AppColors
                                                                    .primary),
                                                        shape: WidgetStateProperty
                                                            .all<
                                                                OutlinedBorder>(
                                                          const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  13),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      iconSize: 25,
                                                      color: AppColors.white,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20),
                                                      onPressed: () {
                                                        setState(() {
                                                          travelMode =
                                                              TravelMode
                                                                  .bicycling;
                                                          mixedRoute = false;
                                                        });
                                                      },
                                                      icon: const Icon(Icons
                                                          .pedal_bike_rounded),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    const Text(
                                                      "Pedalar",
                                                      style: AppFonts.text,
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            results(mixedRoute, travelMode,
                                                travelDistance, travelTime),
                                            // if (_routeStartTime != null &&
                                            //     _routeEndTime != null)
                                            //   _buildRouteTimes(),
                                            // ElevatedButton(
                                            //   onPressed: _startRoute,
                                            //   child: const Text('Start Route'),
                                            // ),
                                          ],
                                        ),
                                      )
                                    : setWalkingRoute ||
                                            setBicyclingRoute ||
                                            setDrivingRoute
                                        ? _buildRouteTimes()
                                        : Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                23, 0, 23, 0),
                                            child: Container(
                                              padding: const EdgeInsets.all(15),
                                              decoration: BoxDecoration(
                                                color: AppColors.brightShade,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Row(
                                                children: [
                                                  CircularButton(
                                                    icon: Icons.home,
                                                    label: 'Casa',
                                                    onPressed: () {},
                                                  ),
                                                  const SizedBox(width: 15),
                                                  CircularButton(
                                                    icon: Icons.work,
                                                    label: 'Trabalho',
                                                    onPressed: () {},
                                                  ),
                                                  const SizedBox(width: 20),
                                                  CircularButton(
                                                    icon:
                                                        Icons.favorite_rounded,
                                                    label: 'Vó',
                                                    onPressed: () {},
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                          ],
                        ),
                        Positioned(
                          top: 10,
                          left: 23,
                          right: 23,
                          child: Column(
                            children: [
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).hintColor,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                  ),
                                  height: 4,
                                  width: 40,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.fromLTRB(15, 0, 5, 0),
                                decoration: BoxDecoration(
                                  color: AppColors.brightShade,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: 20,
                                        icon: Icon(
                                          _searchController.text.isEmpty &&
                                                  !_isPolylineDrawn
                                              ? Icons.search
                                              : Icons.arrow_back_ios_rounded,
                                        ),
                                        onPressed: () {
                                          if (setWalkingRoute ||
                                              setDrivingRoute ||
                                              setBicyclingRoute) {
                                            setState(() {
                                              setWalkingRoute = false;
                                              setBicyclingRoute = false;
                                              setDrivingRoute = false;
                                            });
                                          } else {
                                            setState(() {
                                              _isSearchFocused = false;
                                              _isPolylineDrawn = false;
                                              _searchController.clear();
                                              appMapKey.currentState
                                                  ?.clearPolyline();
                                            });
                                            FocusScope.of(context).unfocus();
                                          }
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: Form(
                                        child: TextFormField(
                                          controller: _searchController,
                                          focusNode: _searchFocusNode,
                                          onChanged: (text) {
                                            _onChange();
                                          },
                                          onTap: () {
                                            setState(() {
                                              _isSearchFocused = true;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            filled: true,
                                            hintText: 'Para onde?',
                                            fillColor: AppColors.brightShade,
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
