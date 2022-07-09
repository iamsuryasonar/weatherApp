import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/model/current_weather.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utility.dart';

Future<CurrentWeather> fetchCurrentWeather(Position currentLocation) async {
  print(currentLocation.latitude);
  print(currentLocation.longitude);
  final response = await http.get(
    Uri.parse(
        'https://api.openweathermap.org/dta/2.5/onecall?lat=${currentLocation.latitude}&lon=${currentLocation.longitude}&exclude=minutely&appid=${dotenv.env['API_KEY']}&units=metric'),
  );
  if (response.statusCode == 200) {
    // print(jsonDecode(response.body));
    return CurrentWeather.fromJson(jsonDecode(response.body));
  } else {
    return Future.error(
        '${response.statusCode.toString()} Failed to load weather');
  }
}

Future<Position> _getCurrentPosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  return await Geolocator.getCurrentPosition();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Position> currentLocation;
  late Future<CurrentWeather> currentWeather;

  @override
  void initState() {
    super.initState();
    currentWeather = _getCurrentPosition().then(
      (position) => fetchCurrentWeather(position),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              currentWeather = _getCurrentPosition().then(
                (position) => fetchCurrentWeather(position),
                // onError: (error) {
                //   SnackBar(
                //     content: Text(
                //       '$error',
                //     ),
                //   );
                // },
              );
            });
          },
          child: Column(
            children: [
              const Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(top: 20, left: 10),
                  child: Icon(
                    Icons.menu_rounded,
                    size: 35,
                  ),
                ),
              ),
              FutureBuilder<CurrentWeather>(
                future: currentWeather,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // print('data: ${snapshot.data!.daily}');
                    // print('data: ${snapshot.data!.hourly[0]}');
                    return Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 1,
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 10, bottom: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 290,
                                          child: Text(
                                            snapshot.data!.hourly[0]['weather']
                                                [0]['description'],
                                            softWrap: true,
                                            style: GoogleFonts.nunito(
                                              fontSize: 60,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${snapshot.data!.hourly[0]['temp']}°',
                                          style: GoogleFonts.nunito(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: Image.network(
                                          'http://openweathermap.org/img/wn/${snapshot.data!.hourly[0]['weather'][0]['icon']}@2x.png',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    snapshot.data!.timezone,
                                    style: GoogleFonts.nunito(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: snapshot.data!.daily.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color.fromARGB(
                                        180, 223, 223, 223),
                                  ),
                                  // width: 120,
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 10, bottom: 10),
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10, top: 10, bottom: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Utility().extractDay(snapshot
                                                .data!.daily[index]['dt']),
                                            style: GoogleFonts.nunito(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            Utility().convertEpochToUtc(snapshot
                                                .data!.daily[index]['dt']),
                                            style: GoogleFonts.nunito(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: Image.network(
                                          'http://openweathermap.org/img/wn/${snapshot.data!.daily[index]['weather'][0]['icon']}@2x.png',
                                        ),
                                      ),
                                      Text(
                                        '${snapshot.data!.daily[index]['temp']['max'].toString()}°',
                                        style: GoogleFonts.nunito(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '${snapshot.data!.daily[index]['temp']['min'].toString()}°',
                                        style: GoogleFonts.nunito(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.water_drop_outlined),
                                          Text(
                                            '${snapshot.data!.daily[index]['humidity'].toString()}%',
                                            style: GoogleFonts.nunito(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          // const SizedBox(
                          //   height: 10,
                          // )
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }
                  // By default, show a loading spinner.
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
