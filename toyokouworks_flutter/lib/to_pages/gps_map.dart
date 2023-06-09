import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

// import 'package:google_maps_flutter_web/google_maps_flutter_web.dart'
//     as GoogleMapControllerWeb show GoogleMapController;

class GPSMap extends StatelessWidget {
  const GPSMap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0E1117),
      appBar: AppBar(
        centerTitle: true,
        title: Text('GPS'),
        backgroundColor: Color(0xff161b22),
      ),
      body: GPSMapModel(),
    );
  }
}

class GPSMapModel extends StatefulWidget {
  const GPSMapModel({super.key});

  @override
  State<GPSMapModel> createState() => _GPSMapModelState();
}

class _GPSMapModelState extends State<GPSMapModel> {
  Position? currentPosition;
  late GoogleMapController _controller;
  final Completer<GoogleMapController> _mapController = Completer();
  late StreamSubscription<Position> positionStream;
  late StreamSubscription<Position> initStream;

  static double lat = 35.106575;
  static double lng = 136.983019;
  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(lat, lng),
    zoom: 14,
  );

  double? longitude;
  double? latitude;
  CameraPosition? _currentCamera;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );
  Future<ApiResults>? res;
  late List<Marker> _markers;

  @override
  void initState() {
    super.initState();

    _getLocationAsync();
    Position location;
    Future<void> _getLastLocation(context) async {
      Position? _location = await Geolocator.getLastKnownPosition();
      setState(() {
        location = _location!;
        _currentCamera = CameraPosition(
            target: LatLng(location.latitude, location.longitude), zoom: 14);
      });
    }

    Future<Widget> _getLocation(context) async {
      Position _location = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print(_location);
      setState(() {
        location = _location;
        _currentCamera = CameraPosition(
            target: LatLng(location.latitude, location.longitude), zoom: 14);
      });
      return GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _currentCamera ?? _kGooglePlex,
        myLocationEnabled: true,
        onMapCreated: _mapController.complete,
      );
    }

    _getLastLocation(context);
    _getLocation(context);

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      currentPosition = position;
      setState(() {
        currentPosition = position;
        _currentCamera = CameraPosition(
            target:
                LatLng(currentPosition!.latitude, currentPosition!.longitude),
            zoom: 14);
      });
      print(position == null
          ? 'Unknown'
          : '${position.latitude.toString()}, ${position.longitude.toString()}');
    });

    var request = new LastRequest(type: 'GET_LAST_DATA');
    res = fetchApiResults(request);

    _markers = <Marker>[];

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {});
    });

    Timer.periodic(
      // 第一引数：繰り返す間隔の時間を設定
      const Duration(seconds: 3),
      // 第二引数：その間隔ごとに動作させたい処理を書く
      (Timer timer) {
        res = fetchApiResults(request);
        // print(_isConnected);
        getMarkers();
        setState(() {});
      },
    );
  }

  late Position position;

  Future<List<Marker>> getMarkers() async {
    var request = new LastRequest(type: 'GET_LAST_DATA');
    res = fetchApiResults(request);
    _markers.clear();

    await res!.then(
      ((data) async {
        print('lat: ${data.message!['Items'][0]['LAT']}');
        Marker marker = Marker(
          markerId: const MarkerId("currentLocation"),
          position: LatLng(double.parse(data.message!['Items'][0]['LAT']),
              double.parse(data.message!['Items'][0]['LNG'])),
        );
        _markers.add(marker);
      }),
    );
    return _markers;
  }

  Future _getLocationAsync() async {
    Widget _page = GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _currentCamera ?? _kGooglePlex,
      myLocationEnabled: true,
      onMapCreated: _mapController.complete,
    );
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    } else {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      longitude = position.longitude;
      latitude = position.latitude;
      _page = GoogleMap(
        initialCameraPosition:
            CameraPosition(target: LatLng(latitude!, longitude!), zoom: 14),
        myLocationEnabled: true,
        onMapCreated: _mapController.complete,
        markers: [
          Marker(
            markerId: MarkerId('marker-1'),
            position: LatLng(latitude!, longitude!),
          ),
        ].toSet(),
      );
      _page = FutureBuilder(
          future: getMarkers(),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: LatLng(latitude!, longitude!), zoom: 14),
                myLocationEnabled: true,
                onMapCreated: _mapController.complete,
                markers: snapshot.data!.toSet(),
              );
            } else if (snapshot.hasError) {
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: LatLng(latitude!, longitude!), zoom: 14),
                myLocationEnabled: true,
                onMapCreated: _mapController.complete,
                markers: [
                  Marker(
                    markerId: MarkerId('marker-1'),
                    position: LatLng(latitude!, longitude!),
                  ),
                ].toSet(),
              );
            }
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(latitude!, longitude!), zoom: 14),
              myLocationEnabled: true,
              onMapCreated: _mapController.complete,
            );
          }));
      return _page;
    }
  }

  Widget build(BuildContext context) {
    Future<void> _animateCamera(double latitude, double longitude) async {
      final mapController = await _mapController.future;

      await mapController
          .animateCamera(CameraUpdate.newLatLng(LatLng(latitude, longitude)));
    }

    // _animateCamera(latitude ?? 35.106575, longitude ?? 136.983019);

    return FutureBuilder(
        future: _getLocationAsync(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!;
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
    // return GoogleMap(
    //   mapType: MapType.normal,
    //   initialCameraPosition: _currentCamera ?? _kGooglePlex,
    //   myLocationEnabled: true,
    //   onMapCreated: _mapController.complete,
    // );
  }
}

class ApiResults {
  final Map<String, dynamic>? message;
  ApiResults({
    this.message,
  });
  factory ApiResults.fromJson(Map<String, dynamic> json) {
    return ApiResults(
      message: json,
    );
  }
}

Future<ApiResults> fetchApiResults(requestedModel) async {
  Uri url = Uri.parse(dotenv.get('API_URL'));
  var request = requestedModel;
  final response = await http.post(url,
      body: json.encode(request.toJson()),
      headers: {"Content-Type": "application/json"});
  if (response.statusCode == 200) {
    print('success');
    return ApiResults.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed');
  }
}

class SampleRequest {
  // final int? id;
  final String? name;
  SampleRequest({
    // this.id,
    this.name,
  });
  Map<String, dynamic> toJson() => {
        // 'id': id,
        'OperationType': name,
      };
}

class LastRequest {
  final String? type;
  LastRequest({
    this.type,
  });
  Map<String, dynamic> toJson() => {
        'OperationType': type,
      };
}

class PutRequest {
  final String? type;
  final List? data;
  PutRequest({
    this.type,
    this.data,
  });
  Map<String, dynamic> toJson() => {
        'OperationType': type,
        'Data': data,
      };
}
