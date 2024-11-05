import 'package:flutter/material.dart';

import '../../../test_encryption/test_enryption.dart';
import '../../../test_image_pick_to_pdf/test_image_pick_to-pdf.dart';
import '../../presentation/modules/encryption_data/screens/choice_page.dart';
import '../../presentation/modules/home/home.dart';
import '../../presentation/modules/medical_records/medical_records.dart';

const String homeScreen = "homeScreen";
const String splashScreen = "splashScreen";
const String pickMedicalRecordScreen = "pickMedicalRecordScreen";
const String testEncryption = "testEncryption";
const String medicalRecordsScreen = "medicalRecordsScreen";
const String imageToPdfScreen = "imageToPdfScreen";
const String choiceScreen = "choiceScreen";

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homeScreen:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      case medicalRecordsScreen:
        return MaterialPageRoute(
          builder: (_) => const MedicalRecordsScreen(),
        );
      case pickMedicalRecordScreen:
        return MaterialPageRoute(
          builder: (_) => const PickMedicalRecordScreen(),
        );
      case choiceScreen:
        return MaterialPageRoute(
          builder: (_) => const ChoiceScreen(),
        );
      case testEncryption:
        return MaterialPageRoute(
          builder: (_) => const TestEncryption(),
        );
      case imageToPdfScreen:
        return MaterialPageRoute(
          builder: (_) => ImageToPdfScreen(),
        );

      // case subCategoryListScreen:
      //   List<dynamic> confirmLocationArguments =
      //   settings.arguments as List<dynamic>;
      //   return CupertinoPageRoute(
      //     builder: (_) => ChangeNotifierProvider<CategoryListProvider>(
      //       create: (context) => CategoryListProvider(),
      //       child: SubCategoryListScreen(
      //         categoryName: confirmLocationArguments[0] as String,
      //         categoryId: confirmLocationArguments[1] as String,
      //       ),
      //     ),
      //   );

      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
