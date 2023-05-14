import 'package:close_caption_converter/view/caption_detail_view.dart';
import 'package:close_caption_converter/view/convert_view.dart';
import 'package:close_caption_converter/view/editing_view.dart';
import 'package:close_caption_converter/view/search_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      initialRoute: "/",
      routes: {
        "/": (context) => const SearchView(),
        "CaptionDetailView": (context) => const CaptionDetailView(),
        "ConvertView": (context) => const ConvertView(),
        "EditingView": (context) => const EditingView(),
      },
    );
  }
}
