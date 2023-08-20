import 'package:flutter/material.dart';
import 'package:happy/theme/app_theme.dart';

class SocialButtonWidget extends StatelessWidget {
  final String imagePhath;
  final String label;
  final VoidCallback onTap;

  const SocialButtonWidget(
      {Key? key,
      required this.imagePhath,
      required this.label,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              height: 55,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Image.asset(
                    imagePhath,
                    width: 27,
                    height: 27,
                  ),
                ],
              ),
            ),
            Expanded(child: Container()),
            Text(label, style: AppTheme.textStyles.button),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }
}
