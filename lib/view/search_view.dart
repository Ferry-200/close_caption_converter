import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final textEditingController = TextEditingController();
  var videoTitle = "None";
  final List<Map<String, dynamic>> videoCaptionMapList = [];

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
    videoCaptionMapList.clear();
  }

  @override
  Widget build(BuildContext context) {
    void getVideoDetail() async {
      videoCaptionMapList.clear();
      var getVideoDetailUrl = Uri.https(
        "api.bilibili.com",
        "x/web-interface/view",
        {"bvid": textEditingController.text},
      );

      var videoDetailResponse = await http.get(getVideoDetailUrl);

      var videoDetailMap = json
          .decode(const Utf8Decoder().convert(videoDetailResponse.bodyBytes));

      videoTitle = videoDetailMap?["data"]?["title"] ?? "None";

      List videoCaptionList =
          videoDetailMap?["data"]?["subtitle"]?["list"] ?? [];

      for (int i = 0; i < videoCaptionList.length; i++) {
        var getCaptionUrl = Uri.parse(videoCaptionList[i]["subtitle_url"]);
        var captionResponse = await http.get(getCaptionUrl);
        videoCaptionMapList.add(json
            .decode(const Utf8Decoder().convert(captionResponse.bodyBytes)));
      }
      if (context.mounted) {
        if (videoTitle == "None") {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Incorrect BVID.")));
        }
        if (videoTitle != "None" && videoCaptionMapList.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("This video doesn't have close caption.")));
        }
      }

      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Close Caption Converter"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: textEditingController,
              decoration: const InputDecoration(
                labelText: "BVid",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: getVideoDetail,
              child: const Text("Search"),
            ),
            const SizedBox(height: 8),
            Text(videoTitle),
            CaptionListView(
              videoCaptionMapList: videoCaptionMapList,
              videoTitle: videoTitle,
            ),
          ],
        ),
      ),
    );
  }
}

class CaptionListView extends StatelessWidget {
  const CaptionListView({
    super.key,
    required this.videoCaptionMapList,
    required this.videoTitle,
  });
  final List<Map<String, dynamic>> videoCaptionMapList;
  final String videoTitle;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
      child: ListView.builder(
        itemCount: videoCaptionMapList.length,
        itemBuilder: (BuildContext context, int index) {
          return CaptionListTile(
            captionMap: videoCaptionMapList[index],
            videoTitle: videoTitle,
          );
        },
      ),
    );
  }
}

class CaptionListTile extends StatelessWidget {
  const CaptionListTile({
    super.key,
    required this.captionMap,
    required this.videoTitle,
  });
  final Map<String, dynamic> captionMap;
  final String videoTitle;

  @override
  Widget build(BuildContext context) {
    var captionOverview = SizedBox(
      width: 200.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              "${captionMap["body"][0]["from"]}s -> ${captionMap["body"][0]["to"]}s"),
          Text(
            captionMap["body"][0]["content"],
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(
            height: 8.0,
          ),
          Text(
              "${captionMap["body"][2]["from"]}s -> ${captionMap["body"][1]["to"]}s"),
          Text(
            captionMap["body"][1]["content"],
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(
            context,
            "ConvertView",
            arguments: [captionMap["body"], videoTitle],
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              captionOverview,
              IconButton(
                tooltip: "Open fullscreen",
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    "CaptionDetailView",
                    arguments: captionMap["body"],
                  );
                },
                icon: const Icon(Icons.fullscreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
