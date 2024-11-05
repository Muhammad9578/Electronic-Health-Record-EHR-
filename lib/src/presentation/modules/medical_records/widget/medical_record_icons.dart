import 'package:flutter/material.dart';

class MedicalRecordIcon extends StatelessWidget {
  final String icon;
  final double height;
  final double width;
  final Function()? onTap;

  const MedicalRecordIcon(
      {super.key,
      required this.icon,
      this.onTap,
      this.height = 25,
      this.width = 25});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Image.asset(
        icon,
        height: height,
        width: width,
      ),
    );
  }
}
