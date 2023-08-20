// ignore_for_file: library_private_types_in_public_api, unused_local_variable, use_build_context_synchronously, unused_element, deprecated_member_use

import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:happy/shared/models/user_model.dart';
import 'package:happy/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:uuid/uuid.dart';

// ignore: unused_import
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CadastrarOrfanatoFormPage extends StatefulWidget {
  final LatLng? coordinates;

  const CadastrarOrfanatoFormPage({Key? key, this.coordinates})
      : super(key: key);

  @override
  _CadastrarOrfanatoFormPageState createState() =>
      _CadastrarOrfanatoFormPageState();
}

class _CadastrarOrfanatoFormPageState extends State<CadastrarOrfanatoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _sobreController = TextEditingController();
  final _whatsappController = MaskedTextController(mask: '(00) 000000000');

  final _instrucoesController = TextEditingController();
  final _diaVisitasController = TextEditingController();
  bool _atendeFimDeSemana = false;
  final List<File> _photos = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _sobreController.dispose();
    _whatsappController.dispose();
    _instrucoesController.dispose();
    _diaVisitasController.dispose();
    super.dispose();
  }

  Future<void> _salvarFormulario() async {
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      final nome = _nomeController.text;
      final sobre = _sobreController.text;
      final whatsapp = _whatsappController.text;
      final instrucoes = _instrucoesController.text;
      final diaVisitas = _diaVisitasController.text;

      //Recuperar o UID do usuário
      final instance = await SharedPreferences.getInstance();
      final json = instance.get("user") as String;
      final user = UserModel.fromJson(json);
      final uid = user.uid;
      final dataHoraRegistro = DateTime.now();

      // Salvar as fotos no Firebase Storage
      List<String> photoUrls = [];
      final storageInstance = FirebaseStorage.instance;
      const uuid = Uuid();
      for (int i = 0; i < _photos.length; i++) {
        final randomFileName =
            '${uuid.v4()}.jpg'; // Gera um nome de arquivo aleatório
        final photoRef =
            storageInstance.ref().child('photos/$uid/$randomFileName');
        final uploadTask = photoRef.putFile(_photos[i]);
        final snapshot = await uploadTask.whenComplete(() {});
        final photoUrl = await snapshot.ref.getDownloadURL();
        photoUrls.add(photoUrl);
      }

      // Salvar os dados no Firebase
      final firestoreInstance = FirebaseFirestore.instance;
      final collectionReference = firestoreInstance.collection('orphanages');
      final newOrphanage = {
        'uid': uid,
        'nome': nome,
        'sobre': sobre,
        'whatsapp': whatsapp,
        'instrucoes': instrucoes,
        'diaVisitas': diaVisitas,
        'atendeFimDeSemana': _atendeFimDeSemana,
        'latitude': widget.coordinates?.latitude,
        'longitude': widget.coordinates?.longitude,
        'photos': photoUrls,
        'dataHoraRegistro': dataHoraRegistro,
      };

      collectionReference
          .add(newOrphanage)
          .then((value) => {
                // Sucesso ao salvar no Firebase, faça algo aqui
                debugPrint('Dados do orfanato salvos com sucesso: ${value.id}')
              })
          .catchError(
        // ignore: body_might_complete_normally_catch_error
        (error) {
          // Erro ao salvar no Firebase, trate o erro de acordo com a sua necessidade
          debugPrint('Erro ao salvar os dados do orfanato: $error');
        },
      );

      // vai para Home Page
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _tirarFoto() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.getImage(
        source: ImageSource.camera,
      );
      if (pickedFile != null) {
        final photoFile = File(pickedFile.path);
        setState(() {
          _photos.add(photoFile);
        });
      }
    } catch (e) {
      debugPrint('Erro ao tirar foto: $e');
    }
  }

  Future<void> _escolherFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final photoFile = File(pickedFile.path);
      setState(() {
        _photos.add(photoFile);
      });
    }
  }

  Future<void> _exibirDialogoFoto() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecionar foto'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Tirar foto'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _tirarFoto();
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Escolher da galeria'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _escolherFoto();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.backGround,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFC),
        iconTheme: const IconThemeData(
          color: Color(0xFF15C3D6),
        ),
        title: Text(
          'Adicione um orfanato',
          style: AppTheme.textStyles.appBar,
        ),
        centerTitle: true,
        toolbarHeight: 70,
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Dados',
                        style: AppTheme.textStyles.titleFormCadastro,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Divider(
                        color: AppTheme.colors.divider,
                        thickness: 1,
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Nome',
                        style: AppTheme.textStyles.subTitleFormCadastro,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFD3E2E5), width: 1),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: TextFormField(
                        style: TextStyle(
                          color: AppTheme.colors
                              .textFormcadastro, // Escolha a cor que desejar
                        ),
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o nome do orfanato';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Sobre',
                            style: AppTheme.textStyles.subTitleFormCadastro,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Máximo de 300 catacteres',
                            style: AppTheme
                                .textStyles.subTitleFormCadastroMaxCharacters,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFD3E2E5), width: 1),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: TextFormField(
                        style: TextStyle(
                          color: AppTheme.colors.textFormcadastro,
                        ),
                        maxLines: 5,
                        controller: _sobreController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe informações sobre o orfanato';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Número de WhatsApp',
                        style: AppTheme.textStyles.subTitleFormCadastro,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFD3E2E5), width: 1),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: TextFormField(
                        style: TextStyle(
                          color: AppTheme.colors
                              .textFormcadastro, // Escolha a cor que desejar
                        ),
                        controller: _whatsappController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o número de WhatsApp do orfanato';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Fotos',
                        style: AppTheme.textStyles.subTitleFormCadastro,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    if (_photos.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8.0,
                          crossAxisSpacing: 8.0,
                        ),
                        itemCount: _photos.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Image.file(
                                _photos[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              Positioned(
                                top: 4.0,
                                right: 4.0,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _photos.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                    padding: const EdgeInsets.all(4.0),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    const SizedBox(height: 16.0),
                    DottedBorder(
                      radius: const Radius.circular(20),
                      borderType: BorderType.RRect,
                      dashPattern: const [9, 9],
                      strokeWidth: 1,
                      color: const Color(0xFF96D2F0),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          color: Colors.white,
                          child: Center(
                            child: IconButton(
                              onPressed: _exibirDialogoFoto,
                              icon: Icon(
                                Icons.add,
                                color: AppTheme.colors.titleOnboarding1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Visitação',
                        style: AppTheme.textStyles.titleFormCadastro,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Divider(
                        color: AppTheme.colors.divider,
                        thickness: 1,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Instruções',
                        style: AppTheme.textStyles.subTitleFormCadastro,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFD3E2E5), width: 1),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: TextFormField(
                        style: TextStyle(
                          color: AppTheme.colors
                              .textFormcadastro, // Escolha a cor que desejar
                        ),
                        maxLines: 5,
                        controller: _instrucoesController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe as instruções de visita do orfanato';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Dia de Visitas',
                        style: AppTheme.textStyles.subTitleFormCadastro,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFD3E2E5), width: 1),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: TextFormField(
                        style: TextStyle(
                          color: AppTheme.colors
                              .textFormcadastro, // Escolha a cor que desejar
                        ),
                        controller: _diaVisitasController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o dia de visitas do orfanato';
                          }
                          return null;
                        },
                      ),
                    ),
                    SwitchListTile(
                      activeColor: const Color(0xFF39CC83),
                      title: Text(
                        'Atende final de semana',
                        style: AppTheme.textStyles.subTitleFormCadastro,
                      ),
                      value: _atendeFimDeSemana,
                      onChanged: (value) {
                        setState(() {
                          _atendeFimDeSemana = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                    FractionallySizedBox(
                      widthFactor: 1.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF15C3D6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          padding: const EdgeInsets.all(20.0),
                        ),
                        onPressed: _salvarFormulario,
                        child: Text(
                          'Salvar',
                          style: AppTheme.textStyles.btnProximo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
