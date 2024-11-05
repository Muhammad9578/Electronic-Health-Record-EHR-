import 'package:flutter/material.dart';
import 'package:patient_health_record/src/core/themes/app_colors.dart';
import 'package:patient_health_record/src/core/themes/app_images.dart';
import 'package:patient_health_record/src/presentation/modules/encryption_data/models/file_model.dart';

import '../../../../core/helpers/helpers.dart';
import 'display_decrypted_data_screen.dart';
import 'display_text_screen.dart';

class ChoiceScreen extends StatelessWidget {
  const ChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAppDirectoryPath();
    });
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DisplayTextScreen(),
                          ));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(colors: [
                            MyColors.halfWhite,
                            MyColors.mixBlue,
                          ])),
                      child: Column(
                        children: [
                          Image.asset(
                            MyImages.text,
                            height: 50,
                            width: 50,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text("Text"),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DisplayDecryptedDataScreen(
                              type: TypeOfFile.document,
                            ),
                          ));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(colors: [
                            Color(0xffB0BEC5),
                            Color(0xff0097A7),
                          ])),
                      child: Column(
                        children: [
                          Image.asset(
                            MyImages.document,
                            height: 50,
                            width: 50,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text("Documents"),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DisplayDecryptedDataScreen(
                              type: TypeOfFile.image,
                            ),
                          ));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(colors: [
                            Color(0xffB0BEC5),
                            Color(0xff0097A7),
                          ])),
                      child: Column(
                        children: [
                          Image.asset(
                            MyImages.images,
                            height: 50,
                            width: 50,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text("Images"),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DisplayDecryptedDataScreen(
                              type: TypeOfFile.video,
                            ),
                          ));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(colors: [
                            Color(0xffB0BEC5),
                            Color(0xff0097A7),
                          ])),
                      child: Column(
                        children: [
                          Image.asset(
                            MyImages.video,
                            height: 50,
                            width: 50,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text("Videos"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
