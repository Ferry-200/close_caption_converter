import 'package:flutter/material.dart';

import '../model/my_enum.dart';

class ConvertView extends StatefulWidget {
  const ConvertView({super.key});

  @override
  State<ConvertView> createState() => _ConvertViewState();
}

class _ConvertViewState extends State<ConvertView> {
  final titleEditingController = TextEditingController();
  final delayEditingController = TextEditingController();
  var selectedFileExtention = ValueNotifier<FileExtension>(FileExtension.lrc);
  var selectedCaptionStyle = ValueNotifier<CaptionStyle>(CaptionStyle.first);
  late final List arguments;

  @override
  void dispose() {
    super.dispose();
    titleEditingController.dispose();
    delayEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as List;
    final captionRawList = arguments[0] as List;
    final videoTitle = arguments[1] as String;

    titleEditingController.text = videoTitle;
    delayEditingController.text = "0.0";

    String toLyricTime({required String from, double? delay}) {
      late String minuteString;
      late String secondString;
      late double secondAll;

      if (delay == null) {
        secondAll = double.parse(from);
      } else {
        secondAll = double.parse(from) + delay;
      }

      double minute = (secondAll ~/ 60).toDouble();
      double second = secondAll - minute * 60;

      if (minute < 0) {
        minute = 0;
      }
      if (second < 0) {
        second = 0;
      }

      if (minute < 10) {
        minuteString = "0${minute.toInt().toString()}";
      } else {
        minuteString = minute.toInt().toString();
      }

      if (second < 10) {
        secondString = "0${second.toString()}";
      } else {
        secondString = second.toString();
      }

      if (secondString.length > 4) {
        secondString = secondString[0] +
            secondString[1] +
            secondString[2] +
            secondString[3] +
            secondString[4];
      } else if (secondString.length == 4) {
        secondString =
            "${secondString[0]}${secondString[1]}${secondString[2]}${secondString[3]}0";
      }

      return "[$minuteString:$secondString]";
    }

    String toSRTTime({required String from, double? delay}) {
      late String hourString;
      late String minuteString;
      late String secondString;
      late double secondAll;

      if (delay == null) {
        secondAll = double.parse(from);
      } else {
        secondAll = double.parse(from) + delay;
      }

      double hour = (secondAll ~/ 3600).toDouble();
      double minute = (secondAll ~/ 60).toDouble();
      double second = secondAll - minute * 60;

      if (hour < 0) {
        hour = 0;
      }
      if (minute < 0) {
        minute = 0;
      }
      if (second < 0) {
        second = 0;
      }

      if (hour < 10) {
        hourString = "0${hour.toInt().toString()}";
      } else {
        hourString = minute.toInt().toString();
      }

      if (minute < 10) {
        minuteString = "0${minute.toInt().toString()}";
      } else {
        minuteString = minute.toInt().toString();
      }

      if (second < 10) {
        secondString = "0${second.toString()}";
      } else {
        secondString = second.toString();
      }

      if (secondString.length > 5) {
        secondString = secondString[0] +
            secondString[1] +
            secondString[2] +
            secondString[3] +
            secondString[4] +
            secondString[5];
      } else if (secondString.length == 5) {
        secondString =
            "${secondString[0]}${secondString[1]}${secondString[2]}${secondString[3]}${secondString[4]}0";
      } else if (secondString.length == 4) {
        secondString =
            "${secondString[0]}${secondString[1]}${secondString[2]}${secondString[3]}00";
      }

      return "$hourString:$minuteString:$secondString";
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Convert"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (titleEditingController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Title can't be empty.")));
          } else if (double.tryParse(delayEditingController.text) == null) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Delay must be a number.")));
          } else {
            String resultText = "";
            bool hasSecondLine = true;
            if (selectedFileExtention.value == FileExtension.lrc) {
              for (int i = 0; i < captionRawList.length; i++) {
                var lyricTime = toLyricTime(
                    from: captionRawList[i]["from"].toString(),
                    delay: double.parse(delayEditingController.text));
                var lines = captionRawList[i]["content"].toString().split("\n");
                var firstLine = lines[0];
                String secondLine = "";
                if (lines.length > 1) {
                  secondLine = lines[1];
                }

                if (secondLine.isEmpty) {
                  resultText += "$lyricTime$firstLine\n";
                  hasSecondLine = false;
                } else if (selectedCaptionStyle.value == CaptionStyle.first) {
                  resultText += "$lyricTime$firstLine\n";
                } else if (secondLine.isNotEmpty &&
                    selectedCaptionStyle.value ==
                        CaptionStyle.firstWrapSecond) {
                  resultText += "$lyricTime$firstLine\n$lyricTime$secondLine\n";
                } else if (secondLine.isNotEmpty &&
                    selectedCaptionStyle.value ==
                        CaptionStyle.firstSeparatorSecond) {
                  resultText += "$lyricTime$firstLine | $secondLine\n";
                } else if (secondLine.isNotEmpty &&
                    selectedCaptionStyle.value == CaptionStyle.second) {
                  resultText += "$lyricTime$secondLine\n";
                }
              }
            } else if (selectedFileExtention.value == FileExtension.srt) {
              for (int i = 0; i < captionRawList.length; i++) {
                // ignore: non_constant_identifier_names
                var SRTTimeFrom = toSRTTime(
                    from: captionRawList[i]["from"].toString(),
                    delay: double.parse(delayEditingController.text));
                // ignore: non_constant_identifier_names
                var SRTTimeTo = toSRTTime(
                    from: captionRawList[i]["to"].toString(),
                    delay: double.parse(delayEditingController.text));

                resultText += "$i\n$SRTTimeFrom --> $SRTTimeTo\n";

                var lines = captionRawList[i]["content"].toString().split("\n");
                var firstLine = lines[0];
                String secondLine = "";
                if (lines.length > 1) {
                  secondLine = lines[1];
                }

                if (secondLine.isEmpty) {
                  resultText += "$firstLine\n\n";
                  hasSecondLine = false;
                } else if (selectedCaptionStyle.value == CaptionStyle.first) {
                  resultText += "$firstLine\n\n";
                } else if (secondLine.isNotEmpty &&
                    selectedCaptionStyle.value ==
                        CaptionStyle.firstSeparatorSecond) {
                  resultText += "$firstLine | $secondLine\n\n";
                } else if (secondLine.isNotEmpty &&
                    selectedCaptionStyle.value == CaptionStyle.second) {
                  resultText += "$secondLine\n\n";
                }
              }
            }

            if (hasSecondLine == false &&
                selectedCaptionStyle.value != CaptionStyle.first) {
              var noticesnackBar = const SnackBar(
                content: Text(
                    'some caption has only one line, use "only first line" instead.'),
              );
              ScaffoldMessenger.of(context).showSnackBar(noticesnackBar);
            }
            Navigator.pushNamed(
              context,
              "EditingView",
              arguments: [
                resultText,
                titleEditingController.text,
                selectedFileExtention.value
              ],
            );
          }
        },
        icon: const Icon(Icons.arrow_right_alt),
        label: const Text("Convert"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleEditingController,
              decoration: const InputDecoration(
                labelText: "Title",
                helperText: "Used as filename",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            TextField(
              controller: delayEditingController,
              decoration: const InputDecoration(
                labelText: "Delay",
                helperText:
                    "Make the caption show earlier or later. Must be a number.",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            AnimatedBuilder(
              animation: selectedFileExtention,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromRGBO(121, 116, 126, 1)),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(4.0))),
                  child: ButtonTheme(
                    layoutBehavior: ButtonBarLayoutBehavior.constrained,
                    alignedDropdown: true,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        focusColor: Colors.transparent,
                        isExpanded: true,
                        value: selectedFileExtention.value,
                        items: const [
                          DropdownMenuItem(
                              value: FileExtension.lrc, child: Text("lrc")),
                          DropdownMenuItem(
                              value: FileExtension.srt, child: Text("srt")),
                        ],
                        onChanged: (fileExtension) {
                          selectedFileExtention.value = fileExtension!;
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(
              height: 38.0,
              child: Padding(
                padding: EdgeInsets.only(top: 6.0, left: 12.0),
                child: Text(
                  "Convert to",
                  style: TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: selectedFileExtention,
              builder: (context, child) {
                return AnimatedBuilder(
                  animation: selectedCaptionStyle,
                  builder: (context, child) {
                    if (selectedFileExtention.value == FileExtension.srt) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromRGBO(121, 116, 126, 1)),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4.0)),
                        ),
                        child: ButtonTheme(
                          layoutBehavior: ButtonBarLayoutBehavior.constrained,
                          alignedDropdown: true,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              isExpanded: true,
                              value: selectedCaptionStyle.value,
                              items: const [
                                DropdownMenuItem(
                                  value: CaptionStyle.first,
                                  child: Text("only first line"),
                                ),
                                DropdownMenuItem(
                                  value: CaptionStyle.firstSeparatorSecond,
                                  child: Text("first | second"),
                                ),
                                DropdownMenuItem(
                                  value: CaptionStyle.second,
                                  child: Text("only second line"),
                                ),
                              ],
                              onChanged: (captionStyle) {
                                selectedCaptionStyle.value = captionStyle!;
                              },
                            ),
                          ),
                        ),
                      );
                    }
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromRGBO(121, 116, 126, 1)),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4.0)),
                      ),
                      child: ButtonTheme(
                        layoutBehavior: ButtonBarLayoutBehavior.constrained,
                        alignedDropdown: true,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            isExpanded: true,
                            value: selectedCaptionStyle.value,
                            items: const [
                              DropdownMenuItem(
                                value: CaptionStyle.first,
                                child: Text("only first line"),
                              ),
                              DropdownMenuItem(
                                value: CaptionStyle.firstWrapSecond,
                                child: Text("first \\n second"),
                              ),
                              DropdownMenuItem(
                                value: CaptionStyle.firstSeparatorSecond,
                                child: Text("first | second"),
                              ),
                              DropdownMenuItem(
                                value: CaptionStyle.second,
                                child: Text("only second line"),
                              ),
                            ],
                            onChanged: (captionStyle) {
                              selectedCaptionStyle.value = captionStyle!;
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(
              height: 38.0,
              child: Padding(
                padding: EdgeInsets.only(top: 6.0, left: 12.0),
                child: Text(
                  "The style of the caption.",
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
