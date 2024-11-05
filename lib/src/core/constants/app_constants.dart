import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

final GlobalKey<NavigatorState> appNavigationKey = GlobalKey<NavigatorState>();

final getIt = GetIt.instance;

class Constants {
  static Directory? appDocumentsDir;
}
