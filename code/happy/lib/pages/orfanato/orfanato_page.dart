// ignore_for_file: library_private_types_in_public_api, unused_local_variable, unused_import

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:happy/pages/editar_orfanato/editar_orfanato_page.dart';
import 'package:happy/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_share/flutter_share.dart';

class OrfanatoPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String orphanageId; // Adicione o parâmetro orphanageId

  const OrfanatoPage({Key? key, required this.data, required this.orphanageId})
      : super(key: key);

  @override
  _OrfanatoPageState createState() => _OrfanatoPageState();
}

class _OrfanatoPageState extends State<OrfanatoPage> {
  String? address;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    final latitude = widget.data['latitude'] as double;
    final longitude = widget.data['longitude'] as double;
    getAddress(latitude, longitude).then((value) {
      setState(() {
        address = value;
        _createMarkerSet(latitude, longitude).then((marker) {
          setState(() {
            _markers.add(marker);
          });
        });
      });
    });
  }

  Future<Marker> _createMarkerSet(double latitude, double longitude) async {
    final markerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/images/icone_logo.png',
    );

    return Marker(
      markerId: const MarkerId('orphanage'),
      position: LatLng(latitude, longitude),
      icon: markerIcon,
    );
  }

  Future<String> getAddress(double latitude, double longitude) async {
    const apiKey = 'AIzaSyA5_iLfyVOLn1pRAz9ZLxNX04iV-XeQ9qU';
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    // debugPrint('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        return data['results'][0]['formatted_address'];
      }
    }
    return '';
  }

  void launchGoogleMaps(double latitude, double longitude) async {
    final url = 'google.navigation:q=$latitude,$longitude';
    if (await launchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Não foi possível abrir o Google Maps';
    }
  }

  void launchWhatsApp(String phoneNumber) async {
    final url =
        'whatsapp://send?phone=$phoneNumber, &text=Olá, gostaria de visitar o orfanato!';
    if (await launchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Não foi possível abrir o WhatsApp';
    }
  }

  Future<String?> getCurrentUserId() async {
    final instance = await SharedPreferences.getInstance();
    final json = instance.getString("user");
    if (json != null) {
      final userMap = jsonDecode(json);
      return userMap['uid'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.backGround,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              final String orphanageName = widget.data['nome'];
              final String orphanageDescription = widget.data['sobre'];
              final String orphanageAddress =
                  address ?? 'Endereço não disponível';
              final String visitInstructions = widget.data['instrucoes'];
              final String daysOfVisit = widget.data['diaVisitas'];

              final String formattedAddress = Uri.encodeFull(orphanageAddress);
              final String mapsUrl =
                  'https://www.google.com/maps/search/?api=1&query=$formattedAddress';

              final String shareText = '''
                                  Confira o orfanato $orphanageName 👧🏼🧒🏽
                                  \n\n🏩 Sobre o orfanato: $orphanageDescription
                                  \n✅ Instruções para Visita: $visitInstructions
                                  \n📆 Dias de Visita: $daysOfVisit
                                  \n🙏🏻 Faça uma visita: $orphanageAddress
                                  \n\n🤳🏻 Clique no link ao lado para abrir a rota no Google Maps: $mapsUrl''';

              try {
                await FlutterShare.share(
                  title: 'Compartilhar Orfanato',
                  text: shareText,
                  chooserTitle: 'Compartilhar via',
                );
              } catch (e) {
                debugPrint('Erro ao compartilhar: $e');
              }
            },
            icon: const Icon(Icons.share),
          ),
          FutureBuilder<String?>(
            future: getCurrentUserId(),
            builder: (context, snapshot) {
              final currentUserId = snapshot.data;
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orphanages')
                    .doc(widget.orphanageId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(
                      child: Text(
                          'Ocorreu um erro ao carregar os detalhes do orfanato.'),
                    );
                  }

                  final orphanage =
                      snapshot.data!.data() as Map<String, dynamic>?;

                  if (orphanage != null) {
                    final uid = orphanage['uid'];
                  } else {
                    return const Center(
                      child: Text(
                          'Ocorreu um erro ao carregar os detalhes do orfanato.'),
                    );
                  }

                  if (currentUserId != null &&
                      currentUserId == orphanage['uid']) {
                    return Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditarOrfanatoPage(
                                  orphanageId: widget.orphanageId,
                                  data: widget.data,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              );
            },
          ),
        ],
        backgroundColor: const Color(0xFFF9FAFC),
        iconTheme: const IconThemeData(
          color: Color(0xFF15C3D6),
        ),
        title: Text(
          'Orfanato',
          style: AppTheme.textStyles.appBar,
        ),
        centerTitle: true,
        toolbarHeight: 70,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    viewportFraction: 0.95,
                    enableInfiniteScroll: false,
                    height: 270.0,
                    initialPage: 0,
                    padEnds: false,
                  ),
                  items: widget.data['photos'].map<Widget>((photoUrl) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8.0),
                          child: Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data['nome'],
                        style: AppTheme.textStyles.titleOrfanato,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        widget.data['sobre'],
                        style: AppTheme.textStyles.titleDescricao,
                      ),
                      const SizedBox(height: 30.0),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F7FB),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFDDE3F0),
                          ),
                        ),
                        height: 200,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                    widget.data['latitude'] as double,
                                    widget.data['longitude'] as double,
                                  ),
                                  zoom: 15.0,
                                ),
                                markers: _markers,
                                zoomControlsEnabled: false,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 49,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6F7FB),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFB3DAE2),
                                  ),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    launchGoogleMaps(
                                      widget.data['latitude'] as double,
                                      widget.data['longitude'] as double,
                                    );
                                  },
                                  child: Text(
                                    'Ver rotas no Google Maps',
                                    style: AppTheme.textStyles.titleBtnMapa,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      address != null
                          ? Text(
                              address!,
                              style: AppTheme.textStyles.titleDescricao,
                            )
                          : const CircularProgressIndicator(),
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
                        'Instruções para visita',
                        style: AppTheme.textStyles.titleInstruVisita,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        widget.data['instrucoes'],
                        style: AppTheme.textStyles.titleDescricao,
                      ),
                      const SizedBox(height: 25.0),
                      //Dias disponiveis e horarios
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFE6F7FB),
                                  Color(0xFFFFFFFF),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFB3DAE2),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 16.0, top: 8.0),
                                    child: Image.asset(
                                      'assets/images/Clock.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                  Text(
                                    widget.data['diaVisitas'],
                                    style: AppTheme.textStyles.titlediaVisita,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              gradient: widget.data['atendeFimDeSemana']
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFEDFFF6),
                                        Color(0xFFFFFFFF)
                                      ],
                                    )
                                  : const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFFCF0F4),
                                        Color(0xFFFFFFFF)
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: widget.data['atendeFimDeSemana']
                                    ? const Color(0xFFA1E9C5)
                                    : const Color(0xFFFFBCD4),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 16.0, top: 8.0),
                                    child: Image.asset(
                                      widget.data['atendeFimDeSemana']
                                          ? 'assets/images/Alerta_Verde.png'
                                          : 'assets/images/Alerta_Vermelho.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                  Text(
                                    widget.data['atendeFimDeSemana']
                                        ? 'Atendemos fim de semana'
                                        : 'Não atendemos fim de semana',
                                    style: widget.data['atendeFimDeSemana']
                                        ? AppTheme.textStyles.titlediaVisitaTrue
                                        : AppTheme
                                            .textStyles.titlediaVisitaFalse,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25.0),
                      ElevatedButton.icon(
                        onPressed: () {
                          final phoneNumber = widget.data['whatsapp'];
                          launchWhatsApp(phoneNumber);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3CDC8C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: const Size(500, 56),
                        ),
                        icon: Image.asset(
                          'assets/images/Whatsapp.png',
                          width: 20,
                          height: 20,
                        ),
                        label: Text(
                          'Entrar em contato',
                          textAlign: TextAlign.center,
                          style: AppTheme.textStyles.titleWhatsapp,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
