// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:happy/pages/editar_evento/editar_evento_page.dart';
import 'package:happy/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventoPage extends StatelessWidget {
  final String eventId;

  const EventoPage({required this.eventId, Key? key}) : super(key: key);

  Future<String?> getCurrentUserId() async {
    final instance = await SharedPreferences.getInstance();
    final json = instance.getString("user");
    if (json != null) {
      final userMap = jsonDecode(json);
      return userMap['uid'];
    }
    return null;
  }

  Future<void> shareEvent() async {
    final DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .get();

    final eventName = eventSnapshot['nomeEvento'] as String;
    final eventDateTime = eventSnapshot['dataHoraEvento'] as Timestamp;
    final eventDescription = eventSnapshot['sobreEvento'] as String;

    final formattedDate =
        DateFormat('dd/MM/yyyy HH:mm').format(eventDateTime.toDate());

    final shareText =
        '''Confira este evento 🎉🎉🎉\n\n🎈Nome do Evento: $eventName\n🕒 Data e Hora: $formattedDate \n✳️Descrição: $eventDescription''';

    try {
      await FlutterShare.share(
        title: 'Compartilhar Evento',
        text: shareText,
        chooserTitle: 'Compartilhar via',
      );
    } catch (e) {
      debugPrint('Erro ao compartilhar evento: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFC),
        iconTheme: const IconThemeData(
          color: Color(0xFF15C3D6),
        ),
        title: Text(
          'Detalhes do evento',
          style: AppTheme.textStyles.appBar,
        ),
        centerTitle: true,
        toolbarHeight: 70,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF15C3D6)),
            onPressed: shareEvent,
          ),
          FutureBuilder<String?>(
            future: getCurrentUserId(),
            builder: (context, snapshot) {
              final currentUserId = snapshot.data;
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .doc(eventId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(
                      child: Text(
                          'Ocorreu um erro ao carregar os detalhes do evento.'),
                    );
                  }
                  final event = snapshot.data!;
                  final eventName = event['nomeEvento'] as String;
                  final eventDateTime = event['dataHoraEvento'] as Timestamp;
                  final eventDescription = event['sobreEvento'] as String;
                  final eventImageUrl = event['fotoUrl'] as String;

                  // Formate a data e hora do evento
                  final formattedDate = DateFormat('dd/MM/yyyy HH:mm')
                      .format(eventDateTime.toDate());
                  if (currentUserId != null && currentUserId == event['uid']) {
                    return IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF15C3D6)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditarEventoPage(eventId: eventId),
                          ),
                        );
                      },
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Ocorreu um erro ao carregar os detalhes do evento.'),
            );
          }
          final event = snapshot.data!;
          final eventName = event['nomeEvento'] as String;
          final eventDateTime = event['dataHoraEvento'] as Timestamp;
          final eventDescription = event['sobreEvento'] as String;
          final eventImageUrl = event['fotoUrl'] as String;

          // Formate a data e hora do evento
          final formattedDate =
              DateFormat('dd/MM/yyyy HH:mm').format(eventDateTime.toDate());

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 200, // Altura ajustável da imagem
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(eventImageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  eventName,
                  style: AppTheme.textStyles.titleOrfanato,
                ),
                const SizedBox(height: 10),
                Text(
                  formattedDate,
                  style: AppTheme.textStyles.titleDescricao,
                ),
                const SizedBox(height: 20),
                Text(
                  'Descrição:',
                  style: AppTheme.textStyles.titleInstruVisita,
                ),
                const SizedBox(height: 10),
                Text(
                  eventDescription,
                  style: AppTheme.textStyles.titleDescricao,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
