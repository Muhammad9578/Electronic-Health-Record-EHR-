import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as pth;
import 'package:path_provider/path_provider.dart';
import 'package:patient_health_record/src/core/helpers/utils.dart';
import 'package:patient_health_record/src/core/themes/themes.dart';
import 'package:patient_health_record/src/presentation/widgets/buttons.dart';
import 'package:provider/provider.dart';

class PhotographerPickWorkImageScreen extends StatefulWidget {
  PhotographerPickWorkImageScreen({Key? key, this.edit})
      : super(key: key) {
    if (this.edit == null) this.edit = false;
  }

  static const route = "photographerPickWorkImageScreen";
  late bool? edit;

  // final PortfolioModel? portfolioModel;

  @override
  State<PhotographerPickWorkImageScreen> createState() =>
      _PhotographerPickWorkImageScreenState();
}

class _PhotographerPickWorkImageScreenState
    extends State<PhotographerPickWorkImageScreen> {
  List<File> selectedImages = []; // List of selected image
  final _formKey = GlobalKey<FormState>();

  // bool isLoading = false;
  bool convertingImagesToFile = false;
  final eventName = TextEditingController();


  pickImage() async {
    // setState(() async {
      selectedImages = await pickImagesFromGallery(context);
setState(() {

});
    // });
  }
  @override
  void initState() {pickImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery
        .of(context)
        .size
        .width;
    double h = MediaQuery
        .of(context)
        .size
        .height;
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  // controller: fileNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter file name";
                    } else if (value.contains('.')) {
                      return "dot (.) is not allowed";
                    } else {
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "File name",
                    labelText: "File name",
                  ),
                ),
              ),
            ),
            10.spaceY,


            selectedImages.isEmpty // If no images is selected
                ? Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Add Media",
                    // style: MyTextStyle.medium07Black
                    //     .copyWith(fontSize: 14),
                  ),
                  5.spaceY,
                  emptyContainer(h, w),
                ],
              ),
            )
            // If atleast 1 images is selected
                : Expanded(
              child: GridView.builder(
                itemCount: selectedImages.length + 1,
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  crossAxisCount: w <= 400
                      ? 2
                      : w <= 600
                      ? 4
                      : 6,
                ),
                itemBuilder: (BuildContext context, int index) {
                  // TO show selected file
                  return index == selectedImages.length
                      ? emptyContainer(h, w)
                      : Container(
                    margin: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: MyColors
                                .black333
                                .withOpacity(0.3),
                            blurRadius: 5,
                            offset: Offset.zero,
                          ),
                        ],
                        color:
                        MyColors
                            .green.withOpacity(0.1),
                        borderRadius:
                        BorderRadius.circular(10),
                        border: Border.all(
                            width: 1,
                            color: MyColors
                                .black
                                .withOpacity(0.05))),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          top: 0,
                          child: kIsWeb
                              ? Image.network(
                              selectedImages[index].path)
                              : ClipRRect(
                              borderRadius:
                              BorderRadius.circular(
                                  10.0),
                              child: Image.file(
                                selectedImages[index],
                                fit: BoxFit.fill,
                              )),
                        ),
                        Positioned(
                          right: 6,
                          bottom: 6,
                          child: InkWell(
                            onTap: () {
                              selectedImages.removeAt(index);
                              if (!mounted) return;
                              setState(() {});
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: MyColors
                                    .white,
                              ),
                              child: Icon(
                                CupertinoIcons.delete_simple,
                                size: 15,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            15.spaceY,
            // convertingImagesToFile
            //     ? SizedBox.shrink()
            //     : portfolioPrvdr.isloading
            //         ? const Center(
            //             child: CircularProgressIndicator(
            //                 color: AppColors.orange),
            //           )
            //         :
            GreenButton(
              btnText: widget.edit! ? "Update" : "Save Changes",
              btnTap: () {
                if (_formKey.currentState!.validate()) {
                  // if (selectedImages.isEmpty) {
                  //   Toasty.error("Please upload event media");
                  //   return;
                  // }
                  if (!mounted) return;
                  // portfolioPrvdr.savePortfolio(
                  //     context: context,
                  //     selectedImages: selectedImages,
                  //     eventName: eventName.text,
                  //     portfolioModel: widget.portfolioModel,
                  //     loggedInUser: loggedInUser,
                  //     edit: widget.edit);
                }
              },
            )
          ],
        ),
      ),
    );
  }

  emptyContainer(h, w) {
    return InkWell(
      onTap: () async {
        selectedImages = await pickImagesFromGallery(context);
      },
      child: Container(
        height: h * 0.2,
        width: h * 0.2,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border:
            Border.all(width: 1, color: MyColors.black.withOpacity(0.4))),
        child: Icon(CupertinoIcons.camera,
            size: 32, color: MyColors.black.withOpacity(0.3)),
      ),
    );
  }
}
