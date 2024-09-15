import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/services/firestore_service.dart';
import 'package:mobiefy_flutter/views/user_data_success.dart';
import 'package:mobiefy_flutter/widgets/button.dart';

class EmergencyContactForm extends StatefulWidget {
  const EmergencyContactForm({super.key});

  @override
  State<EmergencyContactForm> createState() => _EmergencyContactFormState();
}

class _EmergencyContactFormState extends State<EmergencyContactForm> {
  bool _isEditing = false;
  bool _isSaved = true;

  Future<void> _attemptPop() async {
    final shouldPop = await _handleUnsavedChanges();
    if (mounted && shouldPop) {
      Navigator.of(context).pop(true);
    }
  }

  Future<bool> _handleUnsavedChanges() async {
    if (_isEditing && !_isSaved) {
      // Display a dialog if there are unsaved changes
      return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.white,
              title: Text(
                'Alterações Não Salvas',
                textAlign: TextAlign.center,
                style: AppFonts.text.copyWith(fontWeight: FontWeight.w700),
              ),
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

  // Callback to update the editing and saving state from the child widget
  void _updateEditingState({required bool isEditing, required bool isSaved}) {
    setState(() {
      _isEditing = isEditing;
      _isSaved = isSaved;
    });
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
              'Configuração da Conta',
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
        onStateChange: _updateEditingState, // Pass callback to child
      ),
    );
  }
}

class PageContent extends StatefulWidget {
  final Function({required bool isEditing, required bool isSaved})
      onStateChange;

  const PageContent({super.key, required this.onStateChange});

  @override
  State<PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<PageContent> {
  final TextEditingController _emergencyContactNameController =
      TextEditingController();
  final TextEditingController _emergencyContactNumberController =
      TextEditingController();

  bool _isEditing = false;
  bool _isSaved = true;
  bool _isLoading = false;
  late String _uid;
  bool _performanceAnalyticsAgreement = false;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  Future<void> _onSave() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_emergencyContactNameController.text.isNotEmpty ||
          _emergencyContactNumberController.text.isNotEmpty) {
        await FirestoreService().addEmergencyContact(
          _uid,
          _emergencyContactNameController.text.isNotEmpty
              ? _emergencyContactNameController.text
              : null,
          _emergencyContactNumberController.text.isNotEmpty
              ? _emergencyContactNumberController.text
              : null,
        );
      }

      setState(() {
        _isSaved = true;
        _isEditing = false;
        _isLoading = false;
      });

      widget.onStateChange(isEditing: false, isSaved: true);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserDataSuccess()),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save user data: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onFieldChanged() {
    if (mounted) {
      setState(() {
        _isEditing = true;
        _isSaved = false;
      });
      widget.onStateChange(isEditing: true, isSaved: false);
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
                    const Text("Nome do contato de emergência*",
                        style: AppFonts.inputLabel),
                    const SizedBox(
                      height: 6,
                    ),
                    TextFormField(
                      controller: _emergencyContactNameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.brightShade,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onChanged: (_) => _onFieldChanged(),
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Número*", style: AppFonts.inputLabel),
                    const SizedBox(
                      height: 6,
                    ),
                    TextFormField(
                      controller: _emergencyContactNumberController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.brightShade,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => _onFieldChanged(),
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
