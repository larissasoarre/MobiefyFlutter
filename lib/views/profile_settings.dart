import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/services/firestore_service.dart';
import 'package:mobiefy_flutter/widgets/button.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  Future<void> _attemptPop() async {
    final shouldPop = await _handleUnsavedChanges();
    if (mounted && shouldPop) {
      Navigator.of(context).pop(true);
    }
  }

  Future<bool> _handleUnsavedChanges() async {
    final pageContentState =
        context.findAncestorStateOfType<_PageContentState>();
    if (pageContentState != null &&
        pageContentState._isEditing &&
        !pageContentState._isSaved) {
      return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Unsaved Changes'),
              content: const Text(
                  'You have unsaved changes. Do you really want to leave?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Leave'),
                ),
              ],
            ),
          )) ??
          false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          margin: const EdgeInsets.only(top: 20.0),
          alignment: Alignment.bottomCenter,
          child: AppBar(
            backgroundColor: AppColors.white,
            title: Text(
              'Perfil',
              style: AppFonts.text.copyWith(fontWeight: FontWeight.w700),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: _attemptPop,
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.white,
      body: const PageContent(),
    );
  }
}

class PageContent extends StatefulWidget {
  const PageContent({super.key});

  @override
  State<PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<PageContent> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isEditing = false;
  bool _isSaved = true;
  bool _isLoading = false;
  late String _uid;
  bool _performanceAnalyticsAgreement = false;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (_uid.isNotEmpty) {
      _fetchUserData();
    }
  }

  Future<void> _fetchUserData() async {
    final userData = await FirestoreService().getUserDetails(_uid);

    if (mounted && userData != null) {
      setState(() {
        _fullNameController.text = userData['full_name'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _performanceAnalyticsAgreement =
            userData['performance_analytics_agreement'] ?? false;
      });
    }
  }

  Future<void> _onSave() async {
    setState(() {
      _isLoading = true;
    });

    await FirestoreService().createUser(
      _uid,
      _fullNameController.text,
      _emailController.text,
      _performanceAnalyticsAgreement,
    );

    if (mounted) {
      setState(() {
        _isSaved = true;
        _isEditing = false;
        _isLoading = false;
      });

      // Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nome atualizado com sucesso!',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3), // Display duration
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(38.0, 30.0, 38.0, 0),
      color: AppColors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Form(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Nome Completo", style: AppFonts.inputLabel),
                    const SizedBox(
                      height: 6,
                    ),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onChanged: (_) {
                        if (mounted) {
                          setState(() {
                            _isEditing = true;
                            _isSaved = false;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("E-mail", style: AppFonts.inputLabel),
                    const SizedBox(
                      height: 6,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onChanged: (_) {
                        if (mounted) {
                          setState(() {
                            _isEditing = true;
                            _isSaved = false;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              if (_isLoading)
                const CircularProgressIndicator(
                  color: AppColors.primary,
                )
              else
                CustomButton(
                  label: "Salvar",
                  onPressed: _onSave,
                ),
              const SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }
}
