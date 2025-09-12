class Location {
  final String name;      // 位置名稱 e.g. "R0101"
  final String type;      // 類型 e.g. "location"
  final double? x;        // 可選，座標
  final double? y;
  final double? theta;

  Location({
    required this.name,
    required this.type,
    this.x,
    this.y,
    this.theta,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'],
      type: json['type'],
      x: (json['x'] as num?)?.toDouble(),
      y: (json['y'] as num?)?.toDouble(),
      theta: (json['theta'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (theta != null) 'theta': theta,
    };
  }
}

class MapInfo {
  final String? mapName;
  final List<Location> rLocations;

  MapInfo({
    this.mapName,
    required this.rLocations,
  });

  factory MapInfo.fromJson(Map<String, dynamic> json) {
    return MapInfo(
      mapName: json['mapName'], // This can be null, which is fine now
      rLocations: (json['rLocations'] as List)
          .map((e) => Location.fromJson(e))
          .toList(),
    );
  }
}
