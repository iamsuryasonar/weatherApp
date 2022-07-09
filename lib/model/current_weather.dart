class CurrentWeather {
  final String temp;
  String humidity;
  String icon;
  String description;
  String timezone;
  List<dynamic> daily;
  List<dynamic> hourly;

  CurrentWeather({
    required this.temp,
    required this.humidity,
    required this.icon,
    required this.description,
    required this.timezone,
    required this.daily,
    required this.hourly,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temp: json['current']['temp'].toString(),
      humidity: json['current']['humidity'].toString(),
      icon: json['current']['weather'][0]['icon'],
      description: json['current']['weather'][0]['description'],
      timezone: json['timezone'],
      daily: json['daily'] as List<dynamic>,
      hourly: json['hourly'] as List<dynamic>,
    );
  }
}
