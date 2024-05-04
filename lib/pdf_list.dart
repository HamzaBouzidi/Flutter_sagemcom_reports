import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:share_plus/share_plus.dart';

class PdfListWidget extends StatefulWidget {
  const PdfListWidget({Key? key}) : super(key: key);

  @override
  State<PdfListWidget> createState() => _PdfListWidgetState();
}

class _PdfListWidgetState extends State<PdfListWidget> {
  List<String> pdfUrls = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Initially fetch PDF files
    fetchPdfFiles();
    // Start timer to refresh every 2 seconds
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      fetchPdfFiles();
    });
  }

  @override
  void dispose() {
    // Dispose the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchPdfFiles() async {
    try {
      // Get reference to the folder containing PDFs in Firebase Storage
      firebase_storage.ListResult result = await firebase_storage
          .FirebaseStorage.instance
          .ref('uploads')
          .listAll();

      // Extract URLs of PDF files
      List<String> urls = [];
      result.items.forEach((firebase_storage.Reference ref) {
        urls.add(ref.fullPath);
      });

      setState(() {
        pdfUrls = urls;
      });
    } catch (e) {
      print('Error fetching PDF files: $e');
    }
  }

  Future<void> deletePdfFile(String pdfUrl) async {
    try {
      // Delete file from Firebase Storage
      await firebase_storage.FirebaseStorage.instance.ref(pdfUrl).delete();

      // Remove file from the list
      setState(() {
        pdfUrls.remove(pdfUrl);
      });
    } catch (e) {
      print('Error deleting PDF file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pdfUrls.length,
      itemBuilder: (context, index) {
        String pdfUrl = pdfUrls[index];
        // Extract the file name from the URL
        String fileName =
            pdfUrl.split('/').last; // Get the last part of the URL
        return Padding(
          padding: const EdgeInsets.only(top: 20, left: 5, right: 5),
          child: ListTile(
            title: Text(fileName), // Display file name instead of full URL
            onLongPress: () async {
              // Show confirmation dialog before deleting
              bool deleteConfirmed = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete File'),
                    content: Text('Are you sure you want to delete this file?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Delete'),
                      ),
                    ],
                  );
                },
              );

              if (deleteConfirmed == true) {
                await deletePdfFile(pdfUrl);
              }
            },
            onTap: () async {
              await Share.share('This is your file $pdfUrl');
            },
            tileColor: Colors.grey.withOpacity(0.3),
            leading: const Icon(Icons.picture_as_pdf_outlined),
          ),
        );
      },
    );
  }
}
