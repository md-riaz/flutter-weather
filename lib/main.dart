import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Weather App',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
// variables
  String _cityName = '';
  double _temp = 0;
  String _description = '';
  String _humidity = '';
  String _windSpeed = '';

// methods
  Future getWeather(double lat, double lon) async {
    const apiKey = '56e2ad58b7314ddda44154252222606';
    // get weather from openweather api

    final client = http.Client();

    http.Response response = await client.get(Uri.parse(
        "//api.weatherapi.com/v1/current.json?key=$apiKey&q=$lat,$lon"));

    var results = jsonDecode(response.body);

    if (results['location'] != null) {
      setState(() {
        _cityName = results['location']['name'];
        _temp = results['current']['temp_c'];
        _description = results['current']['condition']['text'];
        _humidity = results['current']['humidity'].toString();
        _windSpeed = results['current']['wind_kph'].toString();
      });
    }
  }

  // get current location
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );
  }

  @override
  void initState() {
    super.initState();

    _determinePosition().then((Position position) {
      getWeather(position.latitude, position.longitude);
    }).catchError((error) {
      print(error);

      AlertDialog(
        title: Text('Error'),
        content: Text(error),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width,
              color: Colors.deepPurple,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      'Currently in $_cityName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '$_temp\u00B0',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      _description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(FontAwesomeIcons.temperatureHalf),
                      title: const Text('Temperature'),
                      trailing: Text('$_temp\u00B0'),
                    ),
                    ListTile(
                      leading: const Icon(FontAwesomeIcons.cloud),
                      title: const Text('Weather'),
                      trailing: Text(_description),
                    ),
                    ListTile(
                      leading: const Icon(FontAwesomeIcons.sun),
                      title: const Text('Humidity'),
                      trailing: Text(_humidity),
                    ),
                    ListTile(
                      leading: const Icon(FontAwesomeIcons.wind),
                      title: const Text('Wind Speed'),
                      trailing: Text(_windSpeed),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
