class RobotInfo {
  final String id;
  final String sn;
  final bool batteryCharging;
  final int battery;
  final String moveStatus;
  final String product;
  final String model;
  final String? mapUuid;
  final String? location;
  final String? imageVersion;
  final String? wifiSsid;
  final int? wifiRssi;

  RobotInfo({
    required this.id,
    required this.sn,
    required this.batteryCharging,
    required this.battery,
    required this.moveStatus,
    required this.product,
    required this.model,
    this.mapUuid,
    this.location,
    this.imageVersion,
    this.wifiSsid,
    this.wifiRssi,
  });

  factory RobotInfo.fromJson(Map<String, dynamic> json) {
    return RobotInfo(
      id: json['_id'] ?? '',
      sn: json['sn'] ?? '',
      batteryCharging: json['batteryCharging'] ?? false,
      battery: json['battery'] ?? 0,
      moveStatus: json['moveStatus']?.toString() ?? '',
      product: json['product'] ?? '',
      model: json['model'] ?? '',
      mapUuid: json['mapUuid'],
      location: json['location'],
      imageVersion: json['imageVersion'],
      wifiSsid: json['wifiSsid'],
      wifiRssi: json['wifiRssi'],
    );
  }
}
