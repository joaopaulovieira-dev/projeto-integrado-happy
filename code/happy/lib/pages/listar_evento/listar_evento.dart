// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happy/pages/evento/evento_page.dart';
import 'package:happy/theme/app_theme.dart';
import 'package:intl/intl.dart'; // Importe o pacote intl

class ListarEventoPage extends StatelessWidget {
  const ListarEventoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFC),
        iconTheme: const IconThemeData(
          color: Color(0xFF15C3D6),
        ),
        title: Text(
          'Lista de Eventos',
          style: AppTheme.textStyles.appBar,
        ),
        centerTitle: true,
        toolbarHeight: 70,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF15C3D6)),
            onPressed: () {
              Navigator.pushNamed(context, '/cadastrar_evento');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Ocorreu um erro ao carregar os eventos.'),
            );
          }
          final events = snapshot.data!.docs;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final eventName = event['nomeEvento'] as String;
              final eventDateTime = event['dataHoraEvento'] as Timestamp;
              final eventDescription = event['sobreEvento'] as String;
              final eventImageUrl = event['fotoUrl'] as String;

              // Formate a data e hora do evento
              final formattedDate =
                  DateFormat('dd/MM/yyyy HH:mm').format(eventDateTime.toDate());

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(eventImageUrl),
                  ),
                  title: Text(eventName),
                  subtitle: Text(formattedDate), // Use a data formatada aqui
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventoPage(eventId: event.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
