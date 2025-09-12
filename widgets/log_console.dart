import 'package:flutter/material.dart';

class LogConsole extends StatelessWidget {
  final List<String> logLines;
  final ScrollController scrollController;

  const LogConsole({required this.logLines, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.black,
      child: ListView.builder(
        controller: scrollController,
        itemCount: logLines.length,
        itemBuilder: (context, index) {
          return Text(
            logLines[index],
            style: TextStyle(color: Colors.white),
          );
        },
      ),
    );
  }
}
