// ignore_for_file: use_build_context_synchronously, deprecated_member_use, library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happy/shared/models/user_model.dart';
import 'package:happy/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class EditarEventoPage extends StatefulWidget {
  final String eventId;

  const EditarEventoPage({super.key, required this.eventId});

  @override
  _EditarEventoPageState createState() => _EditarEventoPageState();
}

class _EditarEventoPageState extends State<EditarEventoPage> {
  List<String> orfanatos = [];
  String? _selectedOrfanatoId;
  String? _selectedOrfanatoName;
  DateTime? _dataHoraEvento;
  String _nomeEvento = '';
  String _sobreEvento = '';
  File? _fotoEvento;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _buscarOrfanatos();
    _buscarEvento();
  }

  Future<void> _buscarOrfanatos() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('orphanages').get();
    setState(() {
      orfanatos = snapshot.docs.map((doc) => doc['nome'] as String).toList();
    });
  }

  Future<void> _buscarEvento() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .get();
      final event = snapshot.data();
      if (event != null) {
        _selectedOrfanatoId = event['orfanatoId'] as String;
        _dataHoraEvento = (event['dataHoraEvento'] as Timestamp).toDate();
        _nomeEvento = event['nomeEvento'] as String;
        _sobreEvento = event['sobreEvento'] as String;
        // Carregar a imagem do evento (se houver) do Firebase Storage
        // Para isso, você precisa ter salvo o URL da imagem no documento do evento
        // _fotoEvento = ...;

        // Buscar o nome do orfanato usando o ID
        final orfanatoSnapshot = await FirebaseFirestore.instance
            .collection('orphanages')
            .doc(_selectedOrfanatoId)
            .get();
        if (orfanatoSnapshot.exists) {
          final orfanatoData = orfanatoSnapshot.data();
          if (orfanatoData != null) {
            _selectedOrfanatoName = orfanatoData['nome'] as String;
          }
        }
      }
    } catch (error) {
      // Tratar o erro caso ocorra
      debugPrint('Erro ao buscar o evento: $error');
    }
    setState(() {});
  }

  Future<void> _salvarEvento() async {
    // Verifica se todos os campos foram preenchidos
    if (_selectedOrfanatoName == null) {
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

    // Implemente a lógica para atualizar o evento no Firebase
    final dataHoraEvento = _dataHoraEvento!;

    final firestoreInstance = FirebaseFirestore.instance;
    final collectionReference = firestoreInstance.collection('events');

    final eventoAtualizado = {
      'uid': uid,
      'orfanatoId': _selectedOrfanatoId,
      'dataHoraRegistro': DateTime.now(),
      'dataHoraEvento': dataHoraEvento,
      'nomeEvento': _nomeEvento,
      'sobreEvento': _sobreEvento,
      'fotoUrl': photoUrl,
      // Outros campos do evento que você precisa atualizar...
    };

    collectionReference
        .doc(widget.eventId)
        .update(eventoAtualizado)
        .then((value) {
      // Sucesso ao atualizar o evento no Firebase
      _showSnackbar('Evento atualizado com sucesso.');
      Navigator.pop(context); // Fecha a tela de edição de evento após salvar
    }).catchError((error) {
      // Erro ao atualizar o evento no Firebase
      _showSnackbar('Erro ao atualizar o evento: $error');
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

  Future<void> _excluirEvento() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: const Text('Deseja realmente excluir o evento?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Fechar a caixa de diálogo sem fazer nada
              },
              child: const Text('Não'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirmar exclusão
              },
              child: const Text('Sim'),
            ),
          ],
        );
      },
    );

    if (confirmed != null && confirmed) {
      final firestoreInstance = FirebaseFirestore.instance;
      final eventRef =
          firestoreInstance.collection('events').doc(widget.eventId);

      try {
        await eventRef.delete();

        // Voltar para a HomePage após a exclusão do evento
        Navigator.pushReplacementNamed(context, "/home");
      } catch (e) {
        // Caso ocorra um erro ao excluir o evento, mostra um diálogo informando o erro
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erro'),
              content: const Text('Erro ao excluir o evento.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
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
          'Editar evento',
          style: AppTheme.textStyles.appBar,
        ),
        centerTitle: true,
        toolbarHeight: 70,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _excluirEvento();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('events')
              .doc(widget.eventId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Erro ao buscar o evento: ${snapshot.error}'),
              );
            } else {
              final event = snapshot.data?.data();
              if (event != null) {
                _selectedOrfanatoId = event['orfanatoId'] as String;
                _dataHoraEvento =
                    (event['dataHoraEvento'] as Timestamp).toDate();
                _nomeEvento = event['nomeEvento'] as String;
                _sobreEvento = event['sobreEvento'] as String;
                // Carregar a imagem do evento (se houver) do Firebase Storage
                // Para isso, você precisa ter salvo o URL da imagem no documento do evento
                // _fotoEvento = ...;
              }
              return Form(
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
                      'Nome do Evento',
                      style: AppTheme.textStyles.subTitleFormCadastro,
                    ),
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
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          _nomeEvento = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o nome do evento';
                          }
                          return null;
                        },
                        initialValue: _nomeEvento,
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
                        border: Border.all(
                            color: const Color(0xFFD3E2E5), width: 1),
                        color: Colors.grey[200], // Cor cinza
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: TextFormField(
                        enabled: false, // Desabilita a edição
                        initialValue: _selectedOrfanatoName,
                        style: TextStyle(
                          color: AppTheme.colors.textFormcadastro,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
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
                        border: Border.all(
                            color: const Color(0xFFD3E2E5), width: 1),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
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
                            style: AppTheme
                                .textStyles.subTitleFormCadastroMaxCharacters,
                          ),
                        ),
                      ],
                    ),
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
                        initialValue: _sobreEvento,
                        maxLines: 3,
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
                        border: Border.all(
                            color: const Color(0xFFD3E2E5), width: 1),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: IconButton(
                        onPressed: _exibirDialogoFoto,
                        icon: const Icon(
                          Icons.photo_camera,
                          color: Color(0xFF15C3D6),
                        ),
                        iconSize: 28,
                      ),
                    ),
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              'Salvar',
                              style: AppTheme.textStyles.btnProximo,
                            ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
