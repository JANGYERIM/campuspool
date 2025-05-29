class PostSummary {
  final int id;
  final String departure;
  final String destination;
  final String nickname;
  final DateTime date;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String fare;

  PostSummary({
    required this.id,
    required this.departure,
    required this.destination,
    required this.nickname,
    required this.date,
    required this.departureTime,
    required this.arrivalTime,
    required this.fare,
  });

  factory PostSummary.fromJson(Map<String, dynamic> json) {
    return PostSummary(
      id: json['id'],
      departure: json['departure'],
      destination: json['destination'],
      nickname: json['nickname'],
      date: DateTime.parse(json['date']),
      departureTime: DateTime.parse('2000-01-01 ${json['departureTime']}'),
      arrivalTime: DateTime.parse('2000-01-01 ${json['arrivalTime']}'),
      fare: json['fare'],
    );
  }
}
