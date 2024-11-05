import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../widgets/widgets.dart';
import '../../../../core/themes/themes.dart';
import 'pick_records_choice_sheet.dart';

class EmptyRecords extends StatelessWidget {
  const EmptyRecords({super.key});

  @override
  Widget build(BuildContext context) {
    return DataNotAvailable(
      image: MyImages.emptyDoc,
      title: "Add a medical record",
      description:
          "A detailed health history helps a doctor diagnose you better",
      btnTap: () {
        // Navigator.pushNamed(context, 'pickMedicalRecordScreen');
        showModalBottomSheet(
          showDragHandle: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          )),
          context: context,
          builder: (context) => PickRecordsChoiceSheet(),
        );
      },
      btnText: "Add a record",
    );
  }
}
