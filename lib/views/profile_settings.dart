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
      body: SingleChildScrollView(
        child: PageContent(
          onStateChange: _updateEditingState, // Pass callback to child
        ),
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
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _pronounController = TextEditingController();

  String? _selectedGender;
  String? _selectedCity;
  String? _selectedDisability;

  bool _isEditing = false;
  bool _isSaved = true;
  bool _isLoading = false;
  late String _uid;
  bool _performanceAnalyticsAgreement = false;

  // Gender options
  final List<String> _genderOptions = [
    'Masculino',
    'Feminino',
    'Prefiro não dizer',
    'Outro (Qual?)'
  ];

  // City options
  final List<String> _cityOptions = [
    'Arujá',
    'Barueri',
    'Biritiba-Mirim',
    'Caieiras',
    'Cajamar',
    'Carapicuíba',
    'Cotia',
    'Diadema',
    'Embu das Artes',
    'Embu-Guaçu',
    'Ferraz de Vasconcelos',
    'Francisco Morato',
    'Franco da Rocha',
    'Guararema',
    'Guarulhos',
    'Itapecerica da Serra',
    'Itapevi',
    'Itaquaquecetuba',
    'Jandira',
    'Juquitiba',
    'Mairiporã',
    'Mauá',
    'Mogi das Cruzes',
    'Osasco',
    'Pirapora do Bom Jesus',
    'Poá',
    'Ribeirão Pires',
    'Rio Grande da Serra',
    'Salesópolis',
    'Santa Isabel',
    'Santana de Parnaíba',
    'Santo André',
    'São Bernardo do Campo',
    'São Caetano do Sul',
    'São Lourenço da Serra',
    'São Paulo',
    'Suzano',
    'Taboão da Serra',
    'Vargem Grande Paulista'
  ];

  // Deficiency options
  final List<String> _disabilityOptions = [
    'Não possuo deficiência',
    'Possuo, mas prefiro não dizer',
    'Deficiência Física',
    'Deficiência Auditiva',
    'Deficiência Visual',
    'Deficiência Intelectual',
    'Deficiência Múltipla'
  ];

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
        _dobController.text = userData['date_of_birth'] ?? '';
        _pronounController.text = userData['pronouns'] ?? '';
        _selectedGender = userData['gender'];
        _selectedCity = userData['city'];
        _selectedDisability = userData['disability'];
        _performanceAnalyticsAgreement =
            userData['performance_analytics_agreement'] ?? false;
      });
    }
  }

  Future<void> _onSave() async {
    setState(() {
      _isLoading = true;
    });

    await FirestoreService().updateAllUserDetails(
      _uid,
      _fullNameController.text,
      _emailController.text,
      _dobController.text,
      _selectedGender,
      _pronounController.text,
      _selectedCity,
      _selectedDisability,
      _performanceAnalyticsAgreement,
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
        _onFieldChanged();
      });
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
                      onChanged: (_) => _onFieldChanged(),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
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
                      onChanged: (_) => _onFieldChanged(),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Data de Nascimento",
                        style: AppFonts.inputLabel),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _dobController,
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.white,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Gênero", style: AppFonts.inputLabel),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      items: _genderOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                          _onFieldChanged();
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pronome", style: AppFonts.inputLabel),
                    const SizedBox(
                      height: 6,
                    ),
                    TextFormField(
                      controller: _pronounController,
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
                    const Text("Cidade", style: AppFonts.inputLabel),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      items: _cityOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value;
                          _onFieldChanged();
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Deficiência", style: AppFonts.inputLabel),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedDisability,
                      items: _disabilityOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDisability = value;
                          _onFieldChanged();
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(15),
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
