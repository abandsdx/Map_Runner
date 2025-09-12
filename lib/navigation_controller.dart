import 'dart:async';
import 'dart:math';
import 'api_service.dart';
import 'models/location_model.dart';

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
    final allMaps = await api.getLocations();
    final selectedMap = allMaps.firstWhere(
      (map) => map.mapName == selectedMapName,
      orElse: () => throw Exception("Map '$selectedMapName' not found"),
    );
    final rLocationNames =
        selectedMap.rLocations.map((loc) => loc.name).toList();
    log("rLocations: ${rLocationNames.join(', ')}");

    for (String locationName in rLocationNames) {
      log("導航至: $locationName");
      await api.navigation(
          missionId: missionId, uId: uId, sn: sn, locationName: locationName);

      int moveStatus = -1; // Use -1 as an initial state before the first check
      while (moveStatus != 10) {
        await Future.delayed(Duration(seconds: 2));
        final robotInfo = await api.getRobotMoveStatus(sn);
        moveStatus = robotInfo.moveStatus;
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
