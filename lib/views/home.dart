import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/services/firestore_service.dart';
import 'package:mobiefy_flutter/views/map.dart';
import 'package:mobiefy_flutter/widgets/app_drawer.dart';
import 'package:mobiefy_flutter/widgets/circular_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        drawer: AppDrawer(scaffoldKey: _scaffoldKey, userName: _userName,),
        body: Stack(
          children: [
            const AppMap(),
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
              initialChildSize: 0.13,
              maxChildSize: 0.3,
              minChildSize: 0.13,
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
                  child: GestureDetector(
                    onVerticalDragUpdate:
                        (details) {}, // Empty handler to ensure drag works
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(23, 5, 23, 0),
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
                        Container(
                          padding: const EdgeInsets.fromLTRB(15, 0, 5, 0),
                          decoration: BoxDecoration(
                              color: AppColors.brightShade,
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            children: [
                              const Icon(Icons.search),
                              Expanded(
                                  child: Form(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    filled: true,
                                    hintText: 'Para onde?',
                                    fillColor: AppColors.brightShade,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                color: AppColors.brightShade,
                                borderRadius: BorderRadius.circular(15)),
                            child: Row(
                              children: [
                                CircularButton(
                                    icon: Icons.home,
                                    label: 'Casa',
                                    onPressed: () {}),
                                const SizedBox(width: 15),
                                CircularButton(
                                    icon: Icons.work,
                                    label: 'Trabalho',
                                    onPressed: () {}),
                                const SizedBox(width: 20),
                                CircularButton(
                                    icon: Icons.favorite_rounded,
                                    label: 'Vó',
                                    onPressed: () {}),
                              ],
                            ))
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
