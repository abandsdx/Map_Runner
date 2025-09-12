import 'dart:convert';
import 'package:http/http.dart' as http;

import 'models/location_model.dart';
import 'models/robot_info_model.dart';

class ApiService {
  final String authHeader; // 從設定帶入 Basic xxx
  final String baseUrlCommand =
      "https://api.nuwarobotics.com/v1/rms/mission/robot/command";
  final String baseUrlRobotInfo =
      "https://api.nuwarobotics.com/v1/rms/mission/robots";
  final String baseUrlLocation =
      "http://152.69.194.121:8000/field-map";

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
      Uri.parse(baseUrlCommand),
      headers: {
        "Authorization": authHeader,
        "Content-Type": "application/json",
      },
      body: payload,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // 2️⃣ Get Locations
  Future<List<MapInfo>> getLocations() async {
    final response = await http.get(
      Uri.parse(baseUrlLocation),
      headers: {"Authorization": authHeader},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MapInfo.fromJson(json)).toList();
    } else {
      throw Exception("Get Locations API failed: ${response.body}");
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
      Uri.parse(baseUrlCommand),
      headers: {
        "Authorization": authHeader,
        "Content-Type": "application/json",
      },
      body: payload,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // 4️⃣ Get Robot moveStatus
  Future<RobotInfo> getRobotMoveStatus(String sn) async {
    final response = await http.get(
      Uri.parse("$baseUrlRobotInfo?sn=$sn"),
      headers: {"Authorization": authHeader},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Assuming the first item in 'payload' is the robot we want
      final robotData = data["data"]["payload"][0];
      return RobotInfo.fromJson(robotData);
    } else {
      throw Exception("Get Robot Info API failed: ${response.body}");
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
      Uri.parse(baseUrlCommand),
      headers: {
        "Authorization": authHeader,
        "Content-Type": "application/json",
      },
      body: payload,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
