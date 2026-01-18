import 'dart:io';
import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:dio/dio.dart';

class PDFReaderScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PDFReaderScreen({super.key, required this.pdfUrl, required this.title});

  @override
  State<PDFReaderScreen> createState() => _PDFReaderScreenState();
}

class _PDFReaderScreenState extends State<PDFReaderScreen> {
  bool _isLoading = true;
  List<PdfPageImage>? _pageImages;
  PdfDocument? _document;

  @override
  void initState() {
    super.initState();
    _preparePdf();
  }

  Future<void> _preparePdf() async {
    try {
      // 1. Download/Cache PDF
      final directory = await getTemporaryDirectory();
      final fileName = widget.pdfUrl.split('/').last;
      final filePath = p.join(directory.path, fileName);
      final file = File(filePath);

      if (!await file.exists()) {
        await Dio().download(widget.pdfUrl, filePath);
      }

      // 2. Load PDF document
      _document = await PdfDocument.openFile(filePath);

      // 3. Render pages as images for PageFlip
      // Note: For large books, we might want to render lazily,
      // but PageFlip usually needs them upfront or we'll have to manage state carefully.
      // We'll limit to a reasonable number or render all if it's small.
      List<PdfPageImage> images = [];
      for (int i = 1; i <= _document!.pagesCount; i++) {
        final page = await _document!.getPage(i);
        final image = await page.render(
          width: page.width * 2,
          height: page.height * 2,
          format: PdfPageImageFormat.jpeg,
          quality: 80,
        );
        if (image != null) {
          images.add(image);
        }
        await page.close();
      }

      if (mounted) {
        setState(() {
          _pageImages = images;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error preparing PDF: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memuat buku: $e")));
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _document?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    "Mempersiapkan pengalaman membaca...",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          : PageFlipWidget(
              backgroundColor: Colors.black,
              children: _pageImages!.map((img) {
                return Center(
                  child: Image.memory(img.bytes, fit: BoxFit.contain),
                );
              }).toList(),
            ),
    );
  }
}
