// Represents a single map's details.
class MapInfo {
  final String? mapName;
  final List<String> rLocations;

  MapInfo({
    this.mapName,
    required this.rLocations,
  });

  factory MapInfo.fromJson(Map<String, dynamic> json) {
    final rLocationsData = json['rLocations'];
    // Ensure rLocations are parsed as a list of strings.
    final locations = (rLocationsData is List)
        ? List<String>.from(rLocationsData)
        : <String>[];

    return MapInfo(
      mapName: json['mapName'],
      rLocations: locations,
    );
  }
}

// Represents a top-level field object from the API, which contains maps.
class Field {
  final String fieldName;
  final List<MapInfo> maps;

  Field({required this.fieldName, required this.maps});

  factory Field.fromJson(Map<String, dynamic> json) {
    final mapsData = json['maps'];
    final mapsList = (mapsData is List)
        ? mapsData
            .map((mapJson) => MapInfo.fromJson(mapJson as Map<String, dynamic>))
            .toList()
        : <MapInfo>[];

    return Field(
      fieldName: json['fieldName'] ?? 'Unnamed Field',
      maps: mapsList,
    );
  }
}
