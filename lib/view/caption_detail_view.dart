import 'package:flutter/material.dart';

class CaptionDetailView extends StatelessWidget {
  const CaptionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final captionRawList = ModalRoute.of(context)!.settings.arguments as List;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Caption Detail"),
      ),
      body: ListView.builder(
        itemCount: captionRawList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
                "${captionRawList[index]["from"]}s -> ${captionRawList[index]["to"]}s"),
            subtitle: Text(captionRawList[index]["content"]),
          );
        },
      ),
    );
  }
}
