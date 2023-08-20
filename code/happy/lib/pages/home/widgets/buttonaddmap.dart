import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ButtonAddMapWidget extends StatelessWidget {
  const ButtonAddMapWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: 327,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orphanages')
                    .snapshots(),
                builder: (context, snapshot) {
                  final orphanagesCount =
                      snapshot.hasData ? snapshot.data!.docs.length : 0;
                  final text = '$orphanagesCount orfanatos encontrados';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      text,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff8FA7B2)),
                    ),
                  );
                },
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF15C3D6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/cadastrar_orfanato');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
