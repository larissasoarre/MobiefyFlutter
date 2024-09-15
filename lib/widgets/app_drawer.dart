import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/services/firestore_service.dart';
import 'package:mobiefy_flutter/views/emergency_contact_settings.dart';
import 'package:mobiefy_flutter/views/privacy_security_settings.dart';
import 'package:mobiefy_flutter/views/login_screen.dart';
import 'package:mobiefy_flutter/views/profile_settings.dart';
import 'package:mobiefy_flutter/views/user_data.dart';
import 'package:mobiefy_flutter/widgets/button.dart';

class AppDrawer extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String userName;

  const AppDrawer({
    super.key,
    required this.scaffoldKey,
    required this.userName,
    required Future<void> Function() onUserNameUpdated,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late String _uid;
  late String _userName;
  bool _completedData = false;

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (_uid.isNotEmpty) {
      _fetchUserData();
    }
  }

  Future<void> _refreshUserName() async {
    final name = await _fetchUserName();
    if (name != null) {
      setState(() {
        _userName = name; // Update the state with the new username
      });
    }
  }

  // Fetch user data to get the current state of completedData
  Future<void> _fetchUserData() async {
    final userData = await FirestoreService().getUserDetails(_uid);

    if (mounted && userData != null) {
      setState(() {
        _completedData = userData['completed_data'] ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      width: MediaQuery.of(context).size.width,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        children: [
          PreferredSize(
            preferredSize: const Size.fromHeight(80.0),
            child: Container(
              margin: const EdgeInsets.only(top: 20.0),
              alignment: Alignment.bottomCenter,
              child: AppBar(
                backgroundColor: AppColors.white,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the drawer
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(38.0, 0, 38.0, 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Image(
                        image: AssetImage(
                            'lib/assets/images/user_standard_photo.png'),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _userName, // Use the updated userName from state
                        style: AppFonts.heading.copyWith(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      !_completedData
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.all(18),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const UserData()),
                                );
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Concluir a configuração da conta",
                                          style: AppFonts.text.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 7),
                                        Text(
                                          "Desbloqueie todos os serviços de mobilidade no Mobiefy",
                                          style: AppFonts.text
                                              .copyWith(color: AppColors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 16,
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                          Icons.arrow_forward_ios_rounded),
                                      padding: EdgeInsets.zero,
                                      color: AppColors.white,
                                      iconSize: 20,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(height: 30),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.person_outline_rounded,
                            color: AppColors.black),
                        title: const Text('Perfil', style: AppFonts.text),
                        onTap: () async {
                          bool? result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileSettings(),
                            ),
                          );

                          if (result == true) {
                            _refreshUserName(); // Refresh if the profile was updated
                          }
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.lock_outline_rounded,
                            color: AppColors.black),
                        title: const Text('Privacidade e Segurança',
                            style: AppFonts.text),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AppSettings(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.warning_amber_rounded,
                            color: AppColors.black),
                        title: const Text('Botão de Emergência',
                            style: AppFonts.text),
                        onTap: () async {
                          bool? result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const EmergencyContactSettings(),
                            ),
                          );

                          if (result == true) {
                            _refreshUserName(); // Refresh if the profile was updated
                          }
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      CustomButton(
                        label: "Sair",
                        onPressed: () => _logoutDialog(context),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Map<String, dynamic>? userData =
          await FirestoreService().getUserDetails(user.uid);
      return userData?['full_name'] ?? '';
    }
    return null;
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  Future<void> _logoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: Text(
            'Sair da Conta',
            textAlign: TextAlign.center,
            style: AppFonts.text
                .copyWith(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          content: const Text(
            'Você tem certeza de que deseja sair da sua conta?',
            style: AppFonts.text,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Cancelar',
                style: AppFonts.text.copyWith(color: AppColors.primary),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _handleLogout(context); // Proceed with logout
              },
              child: Text(
                'Sair',
                style: AppFonts.text.copyWith(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
