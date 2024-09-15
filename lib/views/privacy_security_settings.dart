import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/services/firestore_service.dart';
import 'package:mobiefy_flutter/widgets/button.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  bool _isEditing = false;
  bool _isSaved = true;
  bool _isLoading = false;
  bool _performanceAnalyticsAgreement = false;
  late String _uid;

  Future<void> _attemptPop() async {
    final shouldPop = await _handleUnsavedChanges();
    if (mounted && shouldPop) {
      Navigator.of(context).pop(true);
    }
  }

  Future<bool> _handleUnsavedChanges() async {
    // Directly check the current state flags
    if (_isEditing && !_isSaved) {
      return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.white,
              title: Text('Alterações Não Salvas',
                  textAlign: TextAlign.center,
                  style: AppFonts.text.copyWith(fontWeight: FontWeight.w700)),
              content: const Text(
                'Você tem alterações que não foram salvas. Você realmente deseja sair?',
                style: AppFonts.text,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancelar',
                      style: AppFonts.text.copyWith(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Sair',
                      style: AppFonts.text.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
          )) ??
          false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (_uid.isNotEmpty) {
      _fetchUserData();
    }
  }

  // Fetch user data to get the current state of performanceAnalyticsAgreement
  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    final userData = await FirestoreService().getUserDetails(_uid);

    if (mounted && userData != null) {
      setState(() {
        _performanceAnalyticsAgreement =
            userData['performance_analytics_agreement'] ?? false;
        _isLoading = false;
      });
    }
  }

  // Handle save button to update performanceAnalyticsAgreement in the database
  Future<void> _onSave() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch the current user data to avoid overwriting other fields
      final currentUserData = await FirestoreService().getUserDetails(_uid);

      final fullName = currentUserData?['full_name'] ?? '';
      final email = currentUserData?['email'] ?? '';

      // Update only the performanceAnalyticsAgreement field
      await FirestoreService().createUser(
        _uid,
        fullName,
        email,
        _performanceAnalyticsAgreement,
      );

      if (mounted) {
        setState(() {
          _isSaved = true;
          _isEditing = false;
          _isLoading = false;
        });

        // Show success message in Portuguese
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Configurações atualizadas com sucesso!',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3), // Display duration
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Handle errors gracefully
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao atualizar configurações: $error',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
              'Privacidade e Segurança',
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
      body: PageContent(
        performanceAnalyticsAgreement: _performanceAnalyticsAgreement,
        isLoading: _isLoading,
        onSave: _onSave,
        onToggleAnalytics: (value) {
          setState(() {
            _performanceAnalyticsAgreement = value;
            _isEditing = true; // Mark as editing when toggled
            _isSaved = false; // Mark as unsaved when toggled
          });
        },
      ),
    );
  }
}

class PageContent extends StatelessWidget {
  final bool performanceAnalyticsAgreement;
  final bool isLoading;
  final VoidCallback onSave;
  final ValueChanged<bool> onToggleAnalytics;

  const PageContent({
    super.key,
    required this.performanceAnalyticsAgreement,
    required this.isLoading,
    required this.onSave,
    required this.onToggleAnalytics,
  });

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
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 8.0),
                      title: const Text('Desempenho & Análise'),
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: performanceAnalyticsAgreement,
                          onChanged: onToggleAnalytics,
                          inactiveTrackColor: AppColors.brightShade,
                          activeTrackColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              if (isLoading)
                const CircularProgressIndicator(
                  color: AppColors.primary,
                )
              else
                CustomButton(
                  label: "Salvar",
                  onPressed: onSave,
                ),
              const SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }
}
