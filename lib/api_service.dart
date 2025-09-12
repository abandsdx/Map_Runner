import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/location_model.dart';
import 'models/robot_info_model.dart';

class ApiService {
  final String authHeader;
  final String baseUrlCommand =
      "https://api.nuwarobotics.com/v1/rms/mission/robot/command";
  final String baseUrlRobotInfo =
      "https://api.nuwarobotics.com/v1/rms/mission/robots";
  final String baseUrlLocation = "http://152.69.194.121:8000/field-map";

  ApiService({required this.authHeader});

  Future<bool> newTask(String sn, String missionId, String uId) async {
    final payload = jsonEncode({
      "missionId": missionId,
      "uId": uId,
      "command": "adapter_new_task_notification",
      "sn": sn
    });
    final response = await http.post(Uri.parse(baseUrlCommand),
        headers: {"Authorization": authHeader, "Content-Type": "application/json"},
        body: payload);
    return response.statusCode == 200;
  }

  Future<List<MapInfo>> getLocations() async {
    print("[DEBUG] Preparing to call http.get for locations...");
    final response = await http.get(Uri.parse(baseUrlLocation),
        headers: {"Authorization": authHeader});
    print("[DEBUG] http.get for locations completed with status: ${response.statusCode}");
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .map((json) => MapInfo.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception("Get Locations API failed: ${response.body}");
    }
  }

  Future<bool> navigation(
      {required String missionId,
      required String uId,
      required String sn,
      required String locationName}) async {
    final payload = jsonEncode({
      "missionId": missionId,
      "uId": uId,
      "command": "adapter_navigation",
      "sn": sn,
      "location": {"name": locationName, "type": "location"}
    });
    final response = await http.post(Uri.parse(baseUrlCommand),
        headers: {"Authorization": authHeader, "Content-Type": "application/json"},
        body: payload);
    return response.statusCode == 200;
  }

  Future<RobotInfo> getRobotMoveStatus(String sn) async {
    final response = await http.get(Uri.parse("$baseUrlRobotInfo?sn=$sn"),
        headers: {"Authorization": authHeader});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final robotData = data["data"]["payload"][0];
      return RobotInfo.fromJson(robotData);
    } else {
      throw Exception("Get Robot Info API failed: ${response.body}");
    }
  }

  Future<bool> completeTask(String sn, String missionId, String uId) async {
    final payload = jsonEncode({
      "missionId": missionId,
      "uId": uId,
      "command": "adapter_complete_task",
      "sn": sn
    });
    final response = await http.post(Uri.parse(baseUrlCommand),
        headers: {"Authorization": authHeader, "Content-Type": "application/json"},
        body: payload);
    return response.statusCode == 200;
  }
}
