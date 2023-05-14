import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import '../model/my_enum.dart';

class EditingView extends StatefulWidget {
  const EditingView({super.key});

  @override
  State<EditingView> createState() => _EditingViewState();
}

class _EditingViewState extends State<EditingView> {
  final resultEditingController = TextEditingController();
  late final List argument;

  @override
  void dispose() {
    super.dispose();
    resultEditingController.dispose();
    argument.clear();
  }

  @override
  Widget build(BuildContext context) {
    argument = ModalRoute.of(context)!.settings.arguments as List;
    resultEditingController.text = argument[0];
    final videoTitle =
        (argument[1] as String).replaceAll("/", "").replaceAll("\\", "");
    final selectedFileExtention = (argument[2] as FileExtension);

    Future<String?> getStorageDir() async {
      if (Platform.isAndroid) {
        return (await getExternalStorageDirectory())?.path;
      } else {
        return (await getApplicationDocumentsDirectory()).path;
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Edit"),
        actions: [
          IconButton(
            tooltip: "Save",
            onPressed: () async {
              late String lyricFileDir;
              if (selectedFileExtention == FileExtension.lrc) {
                lyricFileDir =
                    "${await getStorageDir()}${Platform.pathSeparator}$videoTitle.lrc";
              } else if (selectedFileExtention == FileExtension.srt) {
                lyricFileDir =
                    "${await getStorageDir()}${Platform.pathSeparator}$videoTitle.srt";
              }
              var lyricFile = await File(lyricFileDir).create(recursive: true);
              await lyricFile.writeAsString(resultEditingController.text);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("save to $lyricFileDir")));
                await Navigator.pushNamed(context, "/");
                argument.clear();
              }
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: 16.0,
        ),
        child: TextField(
          maxLines: null,
          controller: resultEditingController,
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      ),
    );
  }
}
