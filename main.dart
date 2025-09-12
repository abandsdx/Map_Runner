import 'package:flutter/material.dart';
import 'api_service.dart';
import 'navigation_controller.dart';
import 'widgets/log_console.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robot Navigation',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NavigationPage(),
    );
  }
}

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  // Provide a placeholder auth token.
  // In a real app, this should come from a secure source.
  final ApiService apiService =
      ApiService(authHeader: "Basic YOUR_AUTH_TOKEN_HERE");
  NavigationController? controller;

  String? selectedMapName;
  List<String> mapNames = [];
  List<String> logLines = [];
  bool isRunning = false;

  final TextEditingController snController = TextEditingController(); // 可輸入 SN

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = NavigationController(apiService, addLog);
    loadMapNames();
  }

  Future<void> loadMapNames() async {
    try {
      // getLocations now returns List<MapInfo>
      final maps = await apiService.getLocations();
      setState(() {
        // We need to extract the mapName from each MapInfo object
        mapNames = maps.map((map) => map.mapName).toList();
      });
    } catch (e) {
      addLog("抓取 MapNames 失敗: $e");
    }
  }

  void addLog(String text) {
    setState(() => logLines.add(text));
    // 自動滾動到底
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> startNavigation() async {
    final sn = snController.text.trim();
    if (sn.isEmpty) {
      addLog("請先輸入 SN!");
      return;
    }
    if (selectedMapName == null) {
      addLog("請先選擇 MapName!");
      return;
    }

    setState(() => isRunning = true);

    try {
      await controller!.startNavigation(sn, selectedMapName!);
      addLog("所有 rLocations 導航完成，任務已完成!");
    } catch (e) {
      addLog("錯誤: $e");
    }

    setState(() => isRunning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Robot Navigation")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text("輸入 SN: "),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: snController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "請輸入 SN",
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text("選擇 MapName: "),
                SizedBox(width: 16),
                DropdownButton<String>(
                  value: selectedMapName,
                  hint: Text("請選擇"),
                  items: mapNames.map((name) {
                    return DropdownMenuItem(
                      value: name,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => selectedMapName = val),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isRunning ? null : startNavigation,
              child: Text(isRunning ? "導航中..." : "開始循環導航"),
            ),
            SizedBox(height: 16),
            Expanded(
              child: LogConsole(
                logLines: logLines,
                scrollController: scrollController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
