import 'package:flutter/material.dart';

import '../../core/themes/themes.dart';

class GreenButton extends StatelessWidget {
  final String btnText;
  final Function()? btnTap;

  const GreenButton({super.key, required this.btnTap, required this.btnText});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: MyColors.lightBlue,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0), // Adjust the radius as needed
            ),
          ),
          onPressed: btnTap,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              btnText,
              style: TextStyle(
                  color: MyColors.white, fontSize: 18, fontWeight: FontWeight.w500),
            ),
          )),
    );
  }
}

class FloatingIconButton extends StatelessWidget {
  final IconData icon;
  final Function()? btnTap;

  const FloatingIconButton({super.key, required this.btnTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      splashColor: Colors.white,
      onTap: btnTap,
      child: Container(
        decoration: BoxDecoration(
            color: MyColors.mixBlue.withOpacity(0.8),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset.zero,
              )
            ]),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Icon(icon),
        ),
      ),
    );
  }
}
