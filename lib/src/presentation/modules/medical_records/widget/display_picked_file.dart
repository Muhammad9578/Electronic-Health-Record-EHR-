import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFScreen extends StatefulWidget {
  final String? path;
  final Uint8List? pdfData;

  PDFScreen({Key? key, this.path, this.pdfData}) : super(key: key);

  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  GlobalKey pdfKey = GlobalKey();

  @override
  void initState() {
    print("widget.path: ${widget.path}");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("in display pdf build : ${widget.path}");
    return Stack(
      children: <Widget>[
        PDFView(
          // gestureRecognizers: ,
          nightMode: false,
          key: pdfKey,
          // pdfData: widget.pdfData,
          filePath: widget.path,
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: true,
          pageFling: false,
          pageSnap: true,
          defaultPage: currentPage!,
          fitPolicy: FitPolicy.BOTH,
          preventLinkNavigation: false,
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
            print(error.toString());
          },
          onPageError: (page, error) {
            setState(() {
              errorMessage = '$page: ${error.toString()}';
            });
            print('$page: ${error.toString()}');
          },
          onViewCreated: (PDFViewController pdfViewController) {
            _controller.complete(pdfViewController);
          },
          onLinkHandler: (String? uri) {
            print('goto uri: $uri');
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
              ),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
                child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text("$currentPage")))),
      ],
    );
  }
}
