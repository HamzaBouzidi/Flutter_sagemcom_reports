import 'dart:io';
import 'package:untitled1/pdf_list.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class PdfScreen extends StatefulWidget {
  const PdfScreen({Key? key}) : super(key: key);

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  String? _filePath;

  Future<void> _importFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = file.path.split('/').last;

      try {
        // Upload file to Firebase Storage
        await firebase_storage.FirebaseStorage.instance
            .ref('uploads/$fileName')
            .putFile(file);

        setState(() {
          _filePath = file.path;
        });
        print('File uploaded to Firebase Storage.');
      } catch (e) {
        print('Error uploading file: $e');
      }
    } else {
      // User canceled the picker
      print('No file picked.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Reports'),
      ),
      body: Center(
        child: PdfListWidget(),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: EdgeInsets.only(right: 16.0, bottom: 16.0),
          child: FloatingActionButton.extended(
            onPressed: _importFile,
            icon: Icon(Icons.file_upload),
            label: Text('Import '),
          ),
        ),
      ),
    );
  }
}
