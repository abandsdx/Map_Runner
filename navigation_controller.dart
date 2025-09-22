import 'dart:async';
import 'dart:math';
import 'api_service.dart';

class NavigationController {
  final ApiService api;
  final Function(String) log;

  NavigationController(this.api, this.log);

  Future<void> startNavigation(String sn, String selectedMapName) async {
    final now = DateTime.now();
    final missionId = "MCS-${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}";
    final uId = (Random().nextInt(9000) + 1000).toString();

    log("啟動 New Task...");
    await api.newTask(sn, missionId, uId);

    log("抓取 Locations...");
    final locations = await api.getLocations();
    final map = locations.firstWhere((e) => e["mapName"] == selectedMapName, orElse: () => throw Exception("Map not found"));
    final List<String> rLocations = List<String>.from(map["rLocations"]);
    log("rLocations: ${rLocations.join(', ')}");

    for (String locationName in rLocations) {
      log("導航至: $locationName");
      await api.navigation(missionId: missionId, uId: uId, sn: sn, locationName: locationName);

      String moveStatus = "";
      while (moveStatus != "10") {
        await Future.delayed(Duration(seconds: 2));
        moveStatus = await api.getRobotMoveStatus(sn);
        log("目前 moveStatus: $moveStatus");
      }
      log("已到達 $locationName");
    }

    log("所有 rLocations 導航完成，開始完成任務...");
    await api.completeTask(sn, missionId, uId);
    log("任務完成!");
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
