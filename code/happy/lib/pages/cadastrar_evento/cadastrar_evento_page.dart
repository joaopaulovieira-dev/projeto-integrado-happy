// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happy/shared/models/user_model.dart';
import 'package:happy/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class CadastrarEventoPage extends StatefulWidget {
  const CadastrarEventoPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CadastrarEventoPageState createState() => _CadastrarEventoPageState();
}

class _CadastrarEventoPageState extends State<CadastrarEventoPage> {
  List<String> _orfanatos = [];
  String? _selectedOrfanato;
  DateTime? _dataHoraEvento;
  String _nomeEvento = '';
  String _sobreEvento = '';
  File? _fotoEvento;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _buscarOrfanatos();
  }

  Future<void> _buscarOrfanatos() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('orphanages').get();
    setState(() {
      _orfanatos = snapshot.docs.map((doc) => doc['nome'] as String).toList();
    });
  }

  Future<void> _salvarEvento() async {
    // Verifica se todos os campos foram preenchidos
    if (_selectedOrfanato == null || _selectedOrfanato!.isEmpty) {
      _showSnackbar('Escolha um orfanato antes de salvar o evento.');
      return;
    }
    if (_dataHoraEvento == null) {
      _showSnackbar('Selecione a data e hora do evento.');
      return;
    }
    if (_nomeEvento.isEmpty) {
      _showSnackbar('Informe o nome do evento.');
      return;
    }
    if (_fotoEvento == null) {
      _showSnackbar('Escolha uma foto para o evento.');
      return;
    }
    if (_sobreEvento.isEmpty) {
      _showSnackbar('Informe as informações do evento.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    //Id do usuario logado
    final instance = await SharedPreferences.getInstance();
    final json = instance.getString("user");
    final user = UserModel.fromJson(json!);
    final uid = user.uid;

    // Salvar a foto do evento no Firebase Storage
    final storageInstance = firebase_storage.FirebaseStorage.instance;
    const uuid = Uuid();
    final randomFileName =
        '${uuid.v4()}.jpg'; // Gera um nome de arquivo aleatório
    final photoRef = storageInstance.ref().child('events/$randomFileName');
    final uploadTask = photoRef.putFile(_fotoEvento!);
    final snapshot = await uploadTask.whenComplete(() {});
    final photoUrl = await snapshot.ref.getDownloadURL();

    // Recupera o ID do orfanato selecionado
    String? selectedOrfanatoId;
    final snapshotOrfanato = await FirebaseFirestore.instance
        .collection('orphanages')
        .where('nome', isEqualTo: _selectedOrfanato)
        .get();
    if (snapshotOrfanato.docs.isNotEmpty) {
      selectedOrfanatoId = snapshotOrfanato.docs.first.id;
    } else {
      _showSnackbar('Orfanato selecionado não encontrado no Firebase.');
      return;
    }

    // Implemente a lógica para salvar o evento no Firebase
    final dataHoraEvento = _dataHoraEvento!;

    final firestoreInstance = FirebaseFirestore.instance;
    final collectionReference = firestoreInstance.collection('events');

    final novoEvento = {
      'uid': uid,
      'orfanatoId': selectedOrfanatoId,
      'dataHoraRegistro': DateTime.now(),
      'dataHoraEvento': dataHoraEvento,
      'nomeEvento': _nomeEvento,
      'sobreEvento': _sobreEvento,
      'fotoUrl': photoUrl,
      // Outros campos do evento que você precisa salvar...
    };

    collectionReference.add(novoEvento).then((value) {
      // Sucesso ao salvar o evento no Firebase
      _showSnackbar('Evento salvo com sucesso.');
      Navigator.pop(context); // Fecha a tela de cadastro de evento após salvar
    }).catchError((error) {
      // Erro ao salvar o evento no Firebase
      _showSnackbar('Erro ao salvar o evento: $error');
    });

    setState(() {
      _isLoading = false;
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _tirarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      final photoFile = File(pickedFile.path);
      setState(() {
        _fotoEvento = photoFile;
      });
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
        _fotoEvento = photoFile;
      });
    }
  }

  Future<void> _selecionarDataHora() async {
    final pickedDateTime = await showDatePicker(
      context: context,
      initialDate: _dataHoraEvento ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDateTime != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dataHoraEvento ?? DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          _dataHoraEvento = DateTime(
            pickedDateTime.year,
            pickedDateTime.month,
            pickedDateTime.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
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
          'Cadastrar evento',
          style: AppTheme.textStyles.appBar,
        ),
        centerTitle: true,
        toolbarHeight: 70,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              Text(
                'Nome',
                style: AppTheme.textStyles.subTitleFormCadastro,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD3E2E5), width: 1),
                  color: Colors.white,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: TextFormField(
                  style: TextStyle(
                    color: AppTheme
                        .colors.textFormcadastro, // Escolha a cor que desejar
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _nomeEvento = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o nome do evento';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                'Orfanato',
                style: AppTheme.textStyles.subTitleFormCadastro,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD3E2E5), width: 1),
                  color: Colors.white,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: DropdownButtonFormField<String>(
                  iconEnabledColor: const Color(0xFF15C3D6),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  items: _orfanatos.map((orfanato) {
                    return DropdownMenuItem(
                      value: orfanato,
                      child: Text(orfanato),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedOrfanato = value;
                    });
                  },
                  value: _selectedOrfanato,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Escolha um orfanato';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                'Data e Hora',
                style: AppTheme.textStyles.subTitleFormCadastro,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD3E2E5), width: 1),
                  color: Colors.white,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: TextField(
                  onTap: _selecionarDataHora, // Alteração aqui!
                  readOnly: true,
                  controller: TextEditingController(
                    text: _dataHoraEvento != null
                        ? DateFormat('dd/MM/yyyy HH:mm')
                            .format(_dataHoraEvento!)
                        : '',
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: Color(0xFF15C3D6),
                      size: 20,
                    ),
                  ),
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
                      style:
                          AppTheme.textStyles.subTitleFormCadastroMaxCharacters,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD3E2E5), width: 1),
                  color: Colors.white,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: TextFormField(
                  style: TextStyle(
                    color: AppTheme
                        .colors.textFormcadastro, // Escolha a cor que desejar
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    _sobreEvento = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe as informações do evento.';
                    }
                    return null;
                  },
                  maxLines:
                      3, // Defina o número de linhas que o campo de texto terá
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                'Foto do Cartaz',
                style: AppTheme.textStyles.subTitleFormCadastro,
              ),
              if (_fotoEvento != null)
                Image.file(
                  _fotoEvento!,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: const Color(0xFFD3E2E5), width: 1),
                    color: Colors.white,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: IconButton(
                    onPressed: _exibirDialogoFoto,
                    icon: const Icon(
                      Icons.photo_camera,
                      color: Color(0xFF15C3D6),
                    ),
                    iconSize: 28,
                  )),
              const SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF15C3D6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.all(20.0),
                ),
                onPressed: () {
                  _salvarEvento();
                },
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
                        'Salvar',
                        style: AppTheme.textStyles.btnProximo,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
