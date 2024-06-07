import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart'; 
import 'package:share_plus/share_plus.dart';

class PdfListWidget extends StatefulWidget {
  const PdfListWidget({Key? key}) : super(key: key);

  @override
  State<PdfListWidget> createState() => _PdfListWidgetState();
}

class _PdfListWidgetState extends State<PdfListWidget> {
  List<Map<String, dynamic>> pdfFiles = [];
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

      // Extract metadata of PDF files
      List<Map<String, dynamic>> files = [];
      for (var ref in result.items) {
        firebase_storage.FullMetadata metadata =
            await ref.getMetadata(); // Get metadata for each file
        Map<String, dynamic> fileData = {
          'name': ref.name, // File name
          'uploadTime': metadata.timeCreated, // Upload time
        };
        files.add(fileData);
      }

      setState(() {
        pdfFiles = files;
      });
    } catch (e) {
      print('Error fetching PDF files: $e');
    }
  }

  Future<void> deletePdfFile(String pdfName) async {
    try {
      // Delete file from Firebase Storage
      await firebase_storage.FirebaseStorage.instance
          .ref('uploads/$pdfName')
          .delete();

      // Remove file from the list
      setState(() {
        pdfFiles.removeWhere((file) => file['name'] == pdfName);
      });
    } catch (e) {
      print('Error deleting PDF file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pdfFiles.length,
      itemBuilder: (context, index) {
        String pdfName = pdfFiles[index]['name'];
        DateTime uploadTime = pdfFiles[index]['uploadTime'];
        // Format upload date
        String formattedDate = DateFormat.yMMMd()
            .add_jm()
            .format(uploadTime); // Format: Jul 5, 2022 12:00 PM

        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(pdfName),
            subtitle: Text('Uploaded on: $formattedDate'),
            onTap: () async {
              await Share.share('This is your file $pdfName');
            },
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                bool deleteConfirmed = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Delete File'),
                      content:
                          Text('Are you sure you want to delete this file?'),
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
                  await deletePdfFile(pdfName);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
