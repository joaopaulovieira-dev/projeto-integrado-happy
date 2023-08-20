// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, unused_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:happy/pages/home/widgets/buttonaddmap.dart';
import 'package:happy/pages/orfanato/orfanato_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController controller;
  late BitmapDescriptor markerIcon;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    setCustomMarker().then((_) {
      loadMarkersFromFirebase();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setCustomMarker().then((_) {
      loadMarkersFromFirebase();
    });
  }

  Future<void> setCustomMarker() async {
    markerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/images/icone_logo.png',
    );
  }

  Future<void> loadMarkersFromFirebase() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('orphanages').get();
    final List<Marker> markers = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final latitude = data['latitude'] as double?;
      final longitude = data['longitude'] as double?;

      if (latitude != null && longitude != null) {
        final marker = Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(latitude, longitude),
          icon: markerIcon,
          onTap: () {
            final orphanageId = doc.id;
            debugPrint('Id do orfanato: ${doc.id}');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OrfanatoPage(data: data, orphanageId: orphanageId),
              ),
            );
            debugPrint('Dados do orfanato: $data');
            debugPrint('Id do orfanato(orphanageId): $orphanageId');
          },
        );
        markers.add(marker);
      }
    }

    setState(() {
      _markers = markers.toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
          true, // Para estender o corpo (conteúdo) atrás da AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/listar_evento');
            },
            child: Image.asset(
              'assets/gif/balao.gif',
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () async {
                final GoogleSignIn googleSignIn = GoogleSignIn();
                try {
                  await googleSignIn
                      .signOut(); // Desconecta o usuário da conta Google
                  Navigator.pushReplacementNamed(
                      context, '/login'); // Navega para a tela de login
                } catch (e) {
                  debugPrint('Erro ao fazer logout da conta Google: $e');
                }
              },
              child: Image.asset(
                'assets/gif/tchau.gif',
                //tamanho: 50,
                height: 40,
                width: 40,
              ),
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(-22.5205, -44.1041),
              zoom: 14.4746,
            ),
            markers: _markers,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              controller = controller;
            },
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.05,
            left: 0,
            right: 0,
            child: const ButtonAddMapWidget(),
          ),
        ],
      ),
    );
  }
}
