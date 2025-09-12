class RobotInfo {
  final String sn;        // 機器人序號
  final String moveStatus;   // 移動狀態 (10 = 到達)

  RobotInfo({
    required this.sn,
    required this.moveStatus,
  });

  factory RobotInfo.fromJson(Map<String, dynamic> json) {
    return RobotInfo(
      sn: json['sn'] ?? '',
      moveStatus: json['moveStatus']?.toString() ?? '',
    );
  }
}
