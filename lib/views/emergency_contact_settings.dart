import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/services/firestore_service.dart';
import 'package:mobiefy_flutter/widgets/button.dart';

class EmergencyContactSettings extends StatefulWidget {
  const EmergencyContactSettings({super.key});

  @override
  State<EmergencyContactSettings> createState() =>
      _EmergencyContactSettingsState();
}

class _EmergencyContactSettingsState extends State<EmergencyContactSettings> {
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
              'Botão de Emergência',
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
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();

  bool _isEditing = false;
  bool _isSaved = true;
  bool _isLoading = false;
  late String _uid;

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
        _contactNameController.text = userData['emergency_contact_name'] ?? '';
        _contactNumberController.text =
            userData['emergency_contact_number'] ?? '';
      });
    }
  }

  Future<void> _onSave() async {
    setState(() {
      _isLoading = true;
    });

    await FirestoreService().updateEmergencyContactDetails(
      _uid,
      _contactNameController.text,
      _contactNumberController.text,
    );

    if (mounted) {
      setState(() {
        _isSaved = true;
        _isEditing = false;
        _isLoading = false;
      });

      // Notify parent about state changes
      widget.onStateChange(isEditing: false, isSaved: true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Dados atualizados com sucesso!',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3), // Display duration
        ),
      );
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
                const Text(
                  "Para sua segurança, configure um contato de emergência. Assim, se você se sentir em perigo, poderá acionar o botão de emergência e uma ligação será feita para a pessoa escolhida — seja um amigo, familiar ou o número de emergência local.",
                  style: AppFonts.text,
                ),
                const SizedBox(height: 40.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Nome do Contato de Emergência",
                        style: AppFonts.inputLabel),
                    const SizedBox(
                      height: 6,
                    ),
                    TextFormField(
                      controller: _contactNameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onChanged: (_) => _onFieldChanged(),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Número do Contato de Emergência",
                        style: AppFonts.inputLabel),
                    const SizedBox(
                      height: 6,
                    ),
                    TextFormField(
                      controller: _contactNumberController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onChanged: (_) => _onFieldChanged(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 30.0),
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
