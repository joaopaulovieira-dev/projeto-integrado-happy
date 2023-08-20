// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:happy/theme/app_theme.dart';

import '../cadastrar_orfanato_form/cadastrar_orfanato_form_page.dart';

class CadastrarOrfanatoPage extends StatefulWidget {
  const CadastrarOrfanatoPage({Key? key}) : super(key: key);

  @override
  _CadastrarOrfanatoPageState createState() => _CadastrarOrfanatoPageState();
}

class _CadastrarOrfanatoPageState extends State<CadastrarOrfanatoPage> {
  final Set<Marker> _markers = {};
  bool _showNextButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(-22.5205, -44.1041),
              zoom: 14.4746,
            ),
            zoomControlsEnabled: false,
            markers: _markers,
            onTap: _handleTap,
          ),
          if (_showNextButton)
            Positioned(
              bottom: 20.0,
              left: 20.0,
              right: 20.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF15C3D6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.all(20.0),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CadastrarOrfanatoFormPage(
                        coordinates: _markers.isNotEmpty
                            ? _markers.first.position
                            : null,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Próximo',
                  style: AppTheme.textStyles.btnProximo,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleTap(LatLng point) async {
    final imageConfig = createLocalImageConfiguration(context);
    final bitmap = await BitmapDescriptor.fromAssetImage(
      imageConfig,
      'assets/images/icone_logo.png',
    );

    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(point.toString()),
          position: point,
          icon: bitmap,
        ),
      );
      _showNextButton = true;
    });
  }
}
