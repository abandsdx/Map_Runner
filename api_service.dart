import 'dart:convert';
import 'package:http/http.dart' as http;
import 'location_model.dart';
import 'robot_info_model.dart';
import 'app_config.dart';

class ApiService {
  final String authHeader; // 從設定帶入 Basic xxx

  ApiService({required this.authHeader});

  // 1️⃣ New Task
  Future<bool> newTask(String sn, String missionId, String uId) async {
    final payload = jsonEncode({
      "missionId": missionId,
      "uId": uId,
      "command": "adapter_new_task_notification",
      "sn": sn
    });

    final response = await http.post(
      Uri.parse(AppConfig.baseUrlCommand),
      headers: {
        "Authorization": authHeader,
        "Content-Type": "application/json",
      },
      body: payload,
    );

    if (response.statusCode == 200) {
      print("✅ New Task 成功");
      return true;
    } else {
      print("❌ New Task 失敗: ${response.body}");
      return false;
    }
  }

  // 2️⃣ Get Locations
  Future<List<MapInfo>> getLocations() async {
    final response = await http.get(
      Uri.parse(AppConfig.baseUrlLocation),
      headers: {"Authorization": authHeader},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print("✅ Locations 載入成功");
      return data.map((json) => MapInfo.fromJson(json)).toList();
    } else {
      print("❌ Get Locations 失敗: ${response.body}");
      throw Exception("Get Locations API failed");
    }
  }

  // 3️⃣ Navigation
  Future<bool> navigation({
    required String missionId,
    required String uId,
    required String sn,
    required String locationName,
  }) async {
    final payload = jsonEncode({
      "missionId": missionId,
      "uId": uId,
      "command": "adapter_navigation",
      "sn": sn,
      "location": {"name": locationName, "type": "location"}
    });

    final response = await http.post(
      Uri.parse(AppConfig.baseUrlCommand),
      headers: {
        "Authorization": authHeader,
        "Content-Type": "application/json",
      },
      body: payload,
    );

    if (response.statusCode == 200) {
      print("✅ Navigation 執行成功 → $locationName");
      return true;
    } else {
      print("❌ Navigation 失敗: ${response.body}");
      return false;
    }
  }

  // 4️⃣ Get Robot moveStatus
  Future<RobotInfo> getRobotMoveStatus(String sn) async {
    final response = await http.get(
      Uri.parse("${AppConfig.baseUrlRobotInfo}?sn=$sn"),
      headers: {"Authorization": authHeader},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Assuming the first item in 'payload' is the robot we want
      final robotData = data["data"]["payload"][0];
      print("📡 Robot moveStatus: ${robotData['moveStatus']}");
      return RobotInfo.fromJson(robotData);
    } else {
      print("❌ Get Robot Info 失敗: ${response.body}");
      throw Exception("Get Robot Info API failed");
    }
  }

  // 5️⃣ Complete Task
  Future<bool> completeTask(String sn, String missionId, String uId) async {
    final payload = jsonEncode({
      "missionId": missionId,
      "uId": uId,
      "command": "adapter_complete_task",
      "sn": sn
    });

    final response = await http.post(
      Uri.parse(AppConfig.baseUrlCommand),
      headers: {
        "Authorization": authHeader,
        "Content-Type": "application/json",
      },
      body: payload,
    );

    if (response.statusCode == 200) {
      print("✅ Complete Task 成功");
      return true;
    } else {
      print("❌ Complete Task 失敗: ${response.body}");
      return false;
    }
  }
}
