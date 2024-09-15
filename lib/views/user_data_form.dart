import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';
import 'package:mobiefy_flutter/constants/fonts.dart';
import 'package:mobiefy_flutter/services/firestore_service.dart';
import 'package:mobiefy_flutter/views/emergency_contact.dart';
import 'package:mobiefy_flutter/views/user_data_success.dart';
import 'package:mobiefy_flutter/widgets/button.dart';

class UserDataForm extends StatefulWidget {
  const UserDataForm({super.key});

  @override
  State<UserDataForm> createState() => _UserDataFormState();
}

class _UserDataFormState extends State<UserDataForm> {
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
            color: AppColors.white,
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
        body: SingleChildScrollView(
          child: PageContent(
            onStateChange: _updateEditingState,
          ),
        ));
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
  final TextEditingController _pronounsController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _selectedGender;
  String? _selectedCity;
  String? _selectedDisability;
  bool _completedData = false;

  String _dobError = '';
  String _genderError = '';
  String _cityError = '';
  String _disabilityError = '';

  String _emergencyContactNumber = '';

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

  // Fetch user data to get the current state of emergencyContactNumber
  Future<void> _fetchUserData() async {
    final userData = await FirestoreService().getUserDetails(_uid);

    if (mounted && userData != null) {
      setState(() {
        _emergencyContactNumber = userData['emergency_contact_number'] ?? '';
      });
    }
  }

  Future<void> _onSave() async {
    setState(() {
      _isLoading = true;
      _completedData = true;
    });

    bool hasError = false;

    if (_dobController.text.isEmpty) {
      setState(() {
        _dobError = 'Este campo é obrigatório.';
        hasError = true;
      });
    }

    if (_selectedGender == null) {
      setState(() {
        _genderError = 'Este campo é obrigatório.';
        hasError = true;
      });
    }

    if (_selectedCity == null) {
      setState(() {
        _cityError = 'Este campo é obrigatório.';
        hasError = true;
      });
    }

    if (_selectedDisability == null) {
      setState(() {
        _disabilityError = 'Este campo é obrigatório.';
        hasError = true;
      });
    }

    // Stop if there are validation errors
    if (hasError) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      if (_dobController.text.isNotEmpty &&
          _selectedGender != null &&
          _selectedCity != null &&
          _selectedDisability != null) {
        await FirestoreService().updateUserDetails(
          _uid,
          _dobController.text.isNotEmpty ? _dobController.text : null,
          _selectedGender,
          _pronounsController.text.isNotEmpty ? _pronounsController.text : null,
          _selectedCity,
          _selectedDisability,
          _completedData,
        );
      }

      setState(() {
        _isSaved = true;
        _isEditing = false;
        _isLoading = false;
      });

      widget.onStateChange(isEditing: false, isSaved: true);

      if (mounted) {
        if (_emergencyContactNumber.isEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EmergencyContact()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserDataSuccess()),
          );
        }
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      // builder: (BuildContext context, Widget? child) => Theme(
      //   data: ThemeData(
      //     datePickerTheme: const DatePickerThemeData(
      //         backgroundColor: AppColors.white,
      //         dividerColor: AppColors.primary,
      //         headerForegroundColor: AppColors.primary),
      //   ),
      //   child: widget,
      // ),
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.day}/${picked.month}/${picked.year}"; // Format the date
        _onFieldChanged();
      });
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
                    const Text("Data de Nascimento*",
                        style: AppFonts.inputLabel),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _dobController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.brightShade,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.calendar_today,
                            color: AppColors.grey,
                          ),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      readOnly: true,
                    ),
                    if (_dobError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _dobError,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 30.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Gênero*", style: AppFonts.inputLabel),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      dropdownColor: AppColors.brightShade,
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
                        fillColor: AppColors.brightShade,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    if (_genderError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _genderError,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 30.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pronomes", style: AppFonts.inputLabel),
                    const SizedBox(
                      height: 6,
                    ),
                    TextFormField(
                      controller: _pronounsController,
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
                    const Text("Cidade*", style: AppFonts.inputLabel),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      dropdownColor: AppColors.brightShade,
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
                        fillColor: AppColors.brightShade,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    if (_cityError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _cityError,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 30.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Deficiência*", style: AppFonts.inputLabel),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedDisability,
                      dropdownColor: AppColors.brightShade,
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
                        fillColor: AppColors.brightShade,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    if (_disabilityError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _disabilityError,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Container(
                  alignment: Alignment.topLeft,
                  child: const Text(
                    '* Campos obrigatórios',
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 30.0),
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
