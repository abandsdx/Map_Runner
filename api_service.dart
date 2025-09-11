import 'dart:convert';
import 'package:http/http.dart' as http;

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
      print("✅ New Task 成功");
      return true;
    } else {
      print("❌ New Task 失敗: ${response.body}");
      return false;
    }
  }

  // 2️⃣ Get Locations
  Future<List<Map<String, dynamic>>> getLocations() async {
    final response = await http.get(
      Uri.parse(baseUrlLocation),
      headers: {"Authorization": authHeader},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ Locations 載入成功");
      return List<Map<String, dynamic>>.from(data);
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
      Uri.parse(baseUrlCommand),
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
  Future<int> getRobotMoveStatus(String sn) async {
    final response = await http.get(
      Uri.parse("$baseUrlRobotInfo?sn=$sn"),
      headers: {"Authorization": authHeader},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final status = data["data"]["payload"][0]["moveStatus"];
      print("📡 Robot moveStatus: $status");
      return status is int ? status : int.parse(status.toString());
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
      Uri.parse(baseUrlCommand),
      headers: {
        "Authorization": authHeader,
        "Content-Type": "application/json",
      },
      body: payload,import 'dart:convert';
import 'package:http/http.dart' as http;

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
      print("✅ New Task 成功");
      return true;
    } else {
      print("❌ New Task 失敗: ${response.body}");
      return false;
    }
  }

  // 2️⃣ Get Locations
  Future<List<Map<String, dynamic>>> getLocations() async {
    final response = await http.get(
      Uri.parse(baseUrlLocation),
      headers: {"Authorization": authHeader},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ Locations 載入成功");
      return List<Map<String, dynamic>>.from(data);
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
      Uri.parse(baseUrlCommand),
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
  Future<int> getRobotMoveStatus(String sn) async {
    final response = await http.get(
      Uri.parse("$baseUrlRobotInfo?sn=$sn"),
      headers: {"Authorization": authHeader},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final status = data["data"]["payload"][0]["moveStatus"];
      print("📡 Robot moveStatus: $status");
      return status is int ? status : int.parse(status.toString());
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
      Uri.parse(baseUrlCommand),
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
