import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class ImageToPdfScreen extends StatefulWidget {
  @override
  _ImageToPdfScreenState createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  List<File> _selectedImages = [];
  bool _isGeneratingPdf = false;

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _generatePdf() async {
    setState(() {
      _isGeneratingPdf = true;
    });

    final pdf = pw.Document();

    for (final image in _selectedImages) {
      final imageBytes = await image.readAsBytes();
      pdf.addPage(
        pw.Page(
          build: (context) =>
              pw.Image(pw.MemoryImage(imageBytes), fit: pw.BoxFit.contain),
        ),
      );
    }

    final output = await getTemporaryDirectory();
    final pdfFile = File('${output.path}/output.pdf');
    await pdfFile.writeAsBytes(await pdf.save());

    setState(() {
      _isGeneratingPdf = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreviewScreen(pdfFile: pdfFile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image to PDF Converter'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _isGeneratingPdf ? null : _pickImages,
            child: Text('Pick Images'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _selectedImages.isEmpty || _isGeneratingPdf
                ? null
                : _generatePdf,
            child: _isGeneratingPdf
                ? const CircularProgressIndicator()
                : const Text('Generate PDF'),
          ),
        ],
      ),
    );
  }
}

class PdfPreviewScreen extends StatelessWidget {
  final File pdfFile;

  PdfPreviewScreen({required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Preview'),
      ),
      body: Center(
        child: PDFView(
          filePath: pdfFile.path,
          // maxPageWidth: 700,
          // build: (format) => pdfFile.readAsBytes(),
        ),
      ),
    );
  }
}
