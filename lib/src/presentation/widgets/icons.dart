import 'package:flutter/material.dart';
import 'package:patient_health_record/src/core/constants/app_constants.dart';
import 'package:patient_health_record/src/core/themes/app_colors.dart';

Widget? backIcon({Function()? onTap}) {
  bool canPop = appNavigationKey!.currentState!.canPop();
  return !canPop ? null : MyBackIcon(onTap: onTap);
}

class MyBackIcon extends StatelessWidget {
  final void Function()? onTap;

  const MyBackIcon({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(50),
      highlightColor: MyColors.green.withOpacity(0.2),
      // splashColor: MyColor.purpleText,
      radius: 10,
      child: SizedBox(
        height: 5,
        width: 5,
        child: Container(
          height: 5,
          width: 5,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_ios,
            size: 20,
          ),
        ),
      ),
    );
  }
}
