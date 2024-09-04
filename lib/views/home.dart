import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/services/firestore_service.dart';
import 'package:mobiefy_flutter/views/map.dart';
import 'package:mobiefy_flutter/widgets/app_drawer.dart';
import 'package:mobiefy_flutter/widgets/circular_button.dart';
import 'package:mobiefy_flutter/widgets/location_list_tile.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _userName = '';
  final _searchController = TextEditingController();
  bool _isSearchFocused = false;
  final FocusNode _searchFocusNode = FocusNode();
  var uuid = const Uuid();
  List<dynamic> listOfLocations = [];
  LatLng endRoute = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _fetchUserName();

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
      print('Place Details Response: ${response.body}'); // Debug response body

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
          print('Details API Error: ${data['status']}');
          return {};
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Exception occurred: $e');
      return {};
    }
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
                // endRoute: LatLng(37.4151, -122.0970),
                endRoute: endRoute,
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
              DraggableScrollableSheet(
                initialChildSize: _isSearchFocused ? 0.79 : 0.3,
                maxChildSize: _isSearchFocused ? 0.79 : 0.3,
                minChildSize: _isSearchFocused ? 0.79 : 0.3,
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
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).hintColor,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                            ),
                            height: 4,
                            width: 40,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(23, 0, 23, 0),
                          child: Container(
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
                                      _searchController.text.isEmpty
                                          ? Icons.search
                                          : Icons.arrow_back_ios_rounded,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isSearchFocused = false;
                                        _searchController.clear();
                                      });
                                      FocusScope.of(context).unfocus();
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
                        ),
                        const SizedBox(height: 20),
                        _isSearchFocused
                            ? Expanded(
                                child: ListView.separated(
                                  controller: scrollController,
                                  padding:
                                      const EdgeInsets.fromLTRB(23, 5, 23, 0),
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
                                    var placeId = location["place_id"] ?? '';

                                    return FutureBuilder<Map<String, dynamic>>(
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
                                                  location["place_id"] ?? '';
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
                                                    _isSearchFocused = false;
                                                    _searchController.clear();
                                                  });
                                                  FocusScope.of(context)
                                                      .unfocus();
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
                            : Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(23, 0, 23, 0),
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: AppColors.brightShade,
                                    borderRadius: BorderRadius.circular(15),
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
                                        icon: Icons.favorite_rounded,
                                        label: 'Vó',
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
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
