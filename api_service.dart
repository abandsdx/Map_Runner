import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class ApiService {
  final String authHeader = "Basic xxx"; // 自行填入
  final String baseUrlCommand = "https://api.nuwarobotics.com/v1/rms/mission/robot/command";
  final String baseUrlRobotInfo = "https://api.nuwarobotics.com/v1/rms/mission/robots";
  final String baseUrlLocation = "http://152.69.194.121:8000/field-map";

  // 1. New Task
  Future<void> newTask(String sn, String missionId, String uId) async {
    final payload = jsonEncode({
      "missionId": missionId,
      "uId": uId,
      "command": "adapter_new_task_notification",
      "sn": sn
    });

    final response = await http.post(
      Uri.parse(baseUrlCommand),
      headers: {"authorization": authHeader, "Content-Type": "application/json"},
      body: payload,
    );
    if (response.statusCode != 200) throw Exception("New Task API failed");
  }

  // 2. Get Locations
  Future<List<Map<String, dynamic>>> getLocations() async {
    final response = await http.get(
      Uri.parse(baseUrlLocation),
      headers: {"Authorization": authHeader},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    throw Exception("Get Locations API failed");
  }

  // 3. Navigation
  Future<void> navigation({required String missionId, required String uId, required String sn, required String locationName}) async {
    final payload = jsonEncode({
      "missionId": missionId,
      "uId": uId,
      "command": "adapter_navigation",
      "sn": sn,
      "location": {"name": locationName, "type": "location"}
    });

    final response = await http.post(
      Uri.parse(baseUrlCommand),
      headers: {"authorization": authHeader, "Content-Type": "application/json"},
      body: payload,
    );
    if (response.statusCode != 200) throw Exception("Navigation API failed");
  }

  // 4. Get Robot moveStatus
  Future<String> getRobotMoveStatus(String sn) async {
    final response = await http.get(
      Uri.parse("$baseUrlRobotInfo?sn=$sn"),
      headers: {"Authorization": authHeader},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["data"]["payload"][0]["moveStatus"].toString();
    }
    throw Exception("Get Robot Info API failed");
  }

  // 5. Complete Task
  Future<void> completeTask(String sn, String missionId, String uId) async {
    final payload = jsonEncode({
      "missionId": missionId,
      "uId": uId,
      "command": "adapter_complete_task",
      "sn": sn
    });

    final response = await http.post(
      Uri.parse(baseUrlCommand),
      headers: {"authorization": authHeader, "Content-Type": "application/json"},
      body: payload,
    );
    if (response.statusCode != 200) throw Exception("Complete Task API failed");
  }
}
