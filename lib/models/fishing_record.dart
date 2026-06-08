class FishingRecord {
  int? id;
  String userId;
  DateTime date;
  String placeName;
  double latitude;
  double longitude;
  String? tackle;
  String? bait;
  String? catchDetails;
  double? temperature;
  String? weatherCondition;
  String? photoPath;

  FishingRecord({
    this.id,
    required this.userId,
    required this.date,
    required this.placeName,
    required this.latitude,
    required this.longitude,
    this.tackle,
    this.bait,
    this.catchDetails,
    this.temperature,
    this.weatherCondition,
    this.photoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'place_name': placeName,
      'latitude': latitude,
      'longitude': longitude,
      'tackle': tackle,
      'bait': bait,
      'catch_details': catchDetails,
      'temperature': temperature,
      'weather_condition': weatherCondition,
      'photo_path': photoPath,
    };
  }

  factory FishingRecord.fromMap(Map<String, dynamic> map) {
    return FishingRecord(
      id: map['id'],
      userId: map['user_id'],
      date: DateTime.parse(map['date']),
      placeName: map['place_name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      tackle: map['tackle'],
      bait: map['bait'],
      catchDetails: map['catch_details'],
      temperature: map['temperature'],
      weatherCondition: map['weather_condition'],
      photoPath: map['photo_path'],
    );
  }
}