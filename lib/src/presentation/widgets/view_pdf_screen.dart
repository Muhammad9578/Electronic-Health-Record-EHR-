import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:patient_health_record/src/presentation/modules/encryption_data/models/file_model.dart';

import '../../../custom_encrypter/encrypter/file_cryptor.dart';
import '../../core/helpers/helpers.dart';

class ViewPDFScreen extends StatefulWidget {
  final FileModel fileModel;

  const ViewPDFScreen({required this.fileModel, Key? key}) : super(key: key);

  @override
  State<ViewPDFScreen> createState() => _ViewPDFScreenState();
}

class _ViewPDFScreenState extends State<ViewPDFScreen> {
  bool isLoading = false;
  File? file;
  final Completer<PDFViewController> _controller = Completer<PDFViewController>();

  // PdfControllerPinch? pdfPinchController;
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  FileCryptor fileCryptor = FileCryptor(
    key: "qwertyuiop@#%^&*()_+1234567890,;",
    iv: 8,
    dir: "KhurramData",
  );

  @override
  void initState() {
    super.initState();
    //downloadFile
    fetchFile();
  }

  void fetchFile() async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 50));
    // file = await decryptTwofish(
    //     widget.fileModel.path!, widget.fileModel.extension!, fileCryptor);
    file = await decryptBblowfish(
        widget.fileModel.path!, widget.fileModel.extension!, fileCryptor);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileModel.name),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : file != null
              ? Stack(
                  children: <Widget>[
                    PDFView(
                      filePath: file!.path,
                      enableSwipe: true,
                      // swipeHorizontal: true,
                      autoSpacing: false,
                      pageFling: true,
                      pageSnap: true,
                      // defaultPage: currentPage!,
                      fitPolicy: FitPolicy.BOTH,
                      preventLinkNavigation: false,
                      // if set to true the link is handled in flutter
                      onRender: (_pages) {
                        setState(() {
                          pages = _pages;
                          isReady = true;
                        });
                      },
                      onError: (error) {
                        setState(() {
                          errorMessage = error.toString();
                        });
                        // print(error.toString());
                      },
                      onPageError: (page, error) {
                        setState(() {
                          errorMessage = '$page: ${error.toString()}';
                        });
                        // print('$page: ${error.toString()}');
                      },
                      // onViewCreated: (PDFViewController pdfViewController) {
                      //   _controller.complete(pdfViewController);
                      // },
                      onLinkHandler: (String? uri) {
                        // print('goto uri: $uri');
                      },
                      onPageChanged: (int? page, int? total) {
                        // print('page change: $page/$total');
                        // setState(() {
                        //   currentPage = page;
                        // });
                      },
                    ),
                    errorMessage.isEmpty
                        ? !isReady
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : Container()
                        : Center(
                            child: Text(errorMessage),
                          )
                  ],
                )

              // pdfPinchController != null
              //     ? PdfViewPinch(
              //   controller: pdfPinchController!,
              // )
              : const Text('unable to open file'),
      /*body: const PDF(
      ).cachedFromUrl(
        'http://africau.edu/images/default/sample.pdf',
        placeholder: (progress) => Center(child: Text('$progress %')),
        errorWidget: (error) => Center(child: Text(error.toString())),
      ),*/
    );
  }
}
