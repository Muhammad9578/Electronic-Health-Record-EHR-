import 'package:flutter/material.dart';
import 'package:patient_health_record/src/data/resources/local/local_database/local_database.dart';

import 'src/core/constants/app_constants.dart';
import 'src/core/routes/app_routes.dart';

void serviceLocator() {
  getIt.registerSingleton<LocalDatabase>(LocalDatabase());
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  serviceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigationKey,
      debugShowCheckedModeBanner: false,
      initialRoute: choiceScreen,
      onGenerateRoute: RouteGenerator.generateRoute,
      // home: AllRecordsScreen(),
    );
  }
}
