import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

const String kFileName = 'example.txt';
const String kFileContent = 'Some random content for this file';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isSubmitting = false;
  bool submittedWithSuccess = false;

  Future<void> _handlePermission() async {
    Permission permission = Platform.isAndroid
        ? Permission.storage
        : Permission.manageExternalStorage;

    var status = await permission.status;
    if (status.isDenied) {
      status = await permission.request();
    }
    if(status.isPermanentlyDenied) {
      await openAppSettings();
    }

    if(!status.isGranted) {
      throw Exception('Has no permission');
    }
  }


  Future<void> _createFile() async {
    try {
      setState(() {
        isSubmitting = true;
      });

      _handlePermission();
      final directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();

      final filePath = '${directory!.path}/$kFileName';
      dev.log('Try to save file in Path $filePath');

      File file = File(filePath);
      await file.create();
      await file.writeAsString(kFileContent);

      await file.resolveSymbolicLinks();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File created in $filePath'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        submittedWithSuccess = true;
      });

    } catch(e, st) {
      dev.log('Something went wrong');
      dev.log(e.toString(), stackTrace: st);

      setState(() {
        submittedWithSuccess = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                submittedWithSuccess
                    ? 'You have created a test file. Check if you can reach it by the file explorer application of your mobile. Or try to create again'
                    : 'Push button to save a file "$kFileName" with content "$kFileContent"',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16,),
              ElevatedButton(
                onPressed: isSubmitting ? null : _createFile,
                child: const Text('Create file'),
              )
            ],
          ),
        ),
      ),
    );
  }
}