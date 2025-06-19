class Waypoint {
  final String uuid;
  final double lat;
  final double lng;
  final int? order;
  final String type;
  final String? description;
  final String? photoUrl;

  Waypoint({
    required this.uuid,
    required this.lat,
    required this.lng,
    required this.type,
    this.order,
    this.description,
    this.photoUrl,
  });

  factory Waypoint.fromJson(Map<String, dynamic> json) => Waypoint(
    uuid: json['uuid'] as String,
    lat: json['lat'] as double,
    lng: (json['lng'] ?? json['lon']) as double,
    type: json['type'] as String,
    order: json['order'] as int?,
    description: json['description'] as String?,
    photoUrl: json['photo_url'] as String?,
  );
}


class WaypointCreate {
  final double lat;
  final double lng;
  final int? order;
  final String type;
  final String? description;
  final String? photoUrl;

  WaypointCreate({
    required this.lat,
    required this.lng,
    this.order,
    required this.type,
    this.description,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
    'order': order,
    'type': type,
    'description': description,
    'photo_url': photoUrl,
  };
}

class WaypointUpdate extends WaypointCreate {
  WaypointUpdate({
    required double lat,
    required double lng,
    int? order,
    required String type,
    String? description,
    String? photoUrl,
  }) : super(
    lat: lat,
    lng: lng,
    order: order,
    type: type,
    description: description,
    photoUrl: photoUrl,
  );
}
