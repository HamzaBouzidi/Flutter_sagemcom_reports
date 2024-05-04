import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<File> pdfFiles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rapport'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: pdfFiles.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(pdfFiles[index].path
                      .split('/')
                      .last),
                  onTap: () {
                    // Ouvrir le fichier PDF lorsqu'il est cliqué
                    // Implémentez cette fonctionnalité selon vos besoins
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: importPdfFile,
            child: Text('Importer un fichier PDF'),
          ),
        ],
      ),
    );
  }

  Future<void> importPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      PlatformFile? file = result.files.isNotEmpty ? result.files.single : null;
      if (file != null && file.bytes != null) {
        Uint8List bytes = file.bytes!;
        String fileName = file.name;
        // Enregistrer le fichier dans le répertoire de l'application
        Directory directory = await getApplicationDocumentsDirectory();
        File localFile = File('${directory.path}/$fileName');
        await localFile.writeAsBytes(bytes);
        setState(() {
          pdfFiles.add(localFile);
        });
      } else {
        // Gérer le cas où le fichier ou les bytes sont nuls
        print("Erreur: Le fichier sélectionné est vide");
      }
    }
  }
}