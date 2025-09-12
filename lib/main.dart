import 'package:flutter/material.dart';
import 'api_service.dart';
import 'navigation_controller.dart';
import 'widgets/log_console.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robot Navigation',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NavigationPage(),
    );
  }
}

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  NavigationPageState createState() => NavigationPageState();
}

class NavigationPageState extends State<NavigationPage> {
  static const String _initialApiKey = "Basic YOUR_AUTH_TOKEN_HERE";
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 5);

  late ApiService apiService;
  late NavigationController controller;

  String? selectedMapName;
  List<String> mapNames = [];
  List<String> logLines = [];
  bool isRunning = false;

  final TextEditingController snController = TextEditingController();
  final TextEditingController apiKeyController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    apiKeyController.text = _initialApiKey;
    _updateApiKey(); // Initial setup using the placeholder
  }

  void _updateApiKey() {
    final newApiKey = apiKeyController.text.trim();
    if (newApiKey.isEmpty) {
      addLog("API 金鑰不可為空!");
      return;
    }

    setState(() {
      apiService = ApiService(authHeader: newApiKey);
      controller = NavigationController(apiService, addLog);
    });

    addLog("API 金鑰已更新，正在重新抓取地圖...");
    loadMapNames(); // Start the process
  }

  Future<void> loadMapNames({int retryCount = 0}) async {
    try {
      final maps = await apiService.getLocations();
      if (!mounted) return;
      setState(() {
        selectedMapName = null;
        mapNames = maps
            .where((map) => map.mapName != null)
            .map((map) => map.mapName!)
            .toSet()
            .toList();
      });
      if (mapNames.isNotEmpty) {
        addLog("地圖列表已成功載入!");
      } else {
        addLog("未找到可用的地圖。");
      }
    } on MapIsProcessingException {
      if (retryCount < _maxRetries) {
        addLog("地圖資料生成中，${_retryDelay.inSeconds}秒後重試... (第 ${retryCount + 1} 次)");
        await Future.delayed(_retryDelay);
        loadMapNames(retryCount: retryCount + 1);
      } else {
        addLog("地圖資料生成超時，請稍後再試。");
      }
    } catch (e) {
      addLog("抓取 MapNames 失敗: $e");
    }
  }

  void addLog(String text) {
    if (!mounted) return;
    setState(() => logLines.add(text));
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

    if (!mounted) return;
    setState(() => isRunning = true);

    try {
      await controller.startNavigation(sn, selectedMapName!);
      addLog("所有 rLocations 導航完成，任務已完成!");
    } catch (e) {
      addLog("錯誤: $e");
    }

    if (!mounted) return;
    setState(() => isRunning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Robot Navigation")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text("輸入 API 金鑰: "),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: apiKeyController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "請輸入 API 金鑰",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _updateApiKey,
                  child: const Text("套用"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("輸入 SN: "),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: snController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "請輸入 SN",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("選擇 MapName: "),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: selectedMapName,
                  hint: const Text("請選擇"),
                  items: mapNames.map((name) {
                    return DropdownMenuItem(value: name, child: Text(name));
                  }).toList(),
                  onChanged: (val) => setState(() => selectedMapName = val),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isRunning ? null : startNavigation,
              child: Text(isRunning ? "導航中..." : "開始循環導航"),
            ),
            const SizedBox(height: 16),
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
