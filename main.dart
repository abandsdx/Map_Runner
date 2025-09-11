import 'package:flutter/material.dart';
import 'api_service.dart';
import 'navigation_controller.dart';
import 'widgets/log_console.dart';
import 'app_config.dart';

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
  final ApiService apiService = ApiService(authHeader: AppConfig.authHeader);
  NavigationController? controller;

  String? selectedMapName;
  List<String> logLines = [];
  bool isRunning = false;
  bool _isCancelled = false;

  final TextEditingController snController = TextEditingController(); // 可輸入 SN

  final ScrollController scrollController = ScrollController();

  Future<List<String>>? _mapNamesFuture;

  @override
  void initState() {
    super.initState();
    controller = NavigationController(apiService, addLog);
    _mapNamesFuture = loadMapNames();
  }

  Future<List<String>> loadMapNames() async {
    try {
      final maps = await apiService.getLocations();
      // Assuming getLocations now returns List<MapInfo>
      return maps.map((map) => map.mapName).toList();
    } catch (e) {
      addLog("抓取 MapNames 失敗: $e");
      // Re-throw the exception to be caught by FutureBuilder
      throw Exception("Failed to load maps");
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

  void cancelNavigation() {
    setState(() => _isCancelled = true);
    addLog("正在取消導航...");
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

    setState(() {
      isRunning = true;
      _isCancelled = false; // Reset cancellation flag
    });

    try {
      await controller!.startNavigation(
        sn,
        selectedMapName!,
        () => _isCancelled, // Pass a function to check the flag
      );
      if (!_isCancelled) {
        addLog("所有 rLocations 導航完成，任務已完成!");
      } else {
        addLog("導航已取消");
      }
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
                FutureBuilder<List<String>>(
                  future: _mapNamesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text("地圖加載失敗", style: TextStyle(color: Colors.red));
                    } else if (snapshot.hasData) {
                      final mapNames = snapshot.data!;
                      return DropdownButton<String>(
                        value: selectedMapName,
                        hint: Text("請選擇"),
                        items: mapNames.map((name) {
                          return DropdownMenuItem(
                            value: name,
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => selectedMapName = val),
                      );
                    } else {
                      return Text("沒有可用的地圖");
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isRunning ? null : startNavigation,
                  child: Text(isRunning ? "導航中..." : "開始循環導航"),
                ),
                SizedBox(width: 16),
                if (isRunning)
                  ElevatedButton(
                    onPressed: cancelNavigation,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text("取消"),
                  ),
              ],
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
