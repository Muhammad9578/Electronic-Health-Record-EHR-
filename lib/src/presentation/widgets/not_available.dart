import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:patient_health_record/src/core/themes/app_colors.dart';

import 'widgets.dart';

class DataNotAvailable extends StatelessWidget {
  final String image;
  final String title, description, btnText;
  final Function()? btnTap;

  const DataNotAvailable(
      {super.key,
      required this.title,
      required this.image,
      required this.description,
      required this.btnTap,
      required this.btnText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 60),
          Image.asset(
            image,
            height: 200,
            width: 200,
          ),
          const SizedBox(height: 25),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 21,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: MyColors.purpleText,
                letterSpacing: -0.3,
                fontSize: 14,
                fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: GreenButton(btnTap: btnTap, btnText: btnText),
          ),
        ],
      ),
    );
  }
}
