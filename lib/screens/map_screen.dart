import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController mapController = MapController();
  LatLng? startLocation;
  LatLng? endLocation;
  List<Marker> markers = [];
  List<Polyline> polylines = [];
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WeSafe'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _startController,
                      decoration: InputDecoration(
                        hintText: 'Enter Start Location',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () => _searchLocation(true),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    TextField(
                      controller: _endController,
                      decoration: InputDecoration(
                        hintText: 'Enter End Location',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () => _searchLocation(false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: LatLng(28.7041, 77.1025),
                zoom: 10,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                  additionalOptions: {
                    'id': 'mapbox/streets-v11',
                    'accessToken': 'pk.eyJ1Ijoid2VzYWZlMTEwMiIsImEiOiJjbHo5dGpyOXAwYzI5Mm1xemV2enZqaG1sIn0.NmxIb-dtvoYn9kx_BZacVA',
                  },
                ),
                MarkerLayer(markers: markers),
                PolylineLayer(polylines: polylines),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.zoom_in),
                  onPressed: _zoomIn,
                ),
                IconButton(
                  icon: Icon(Icons.zoom_out),
                  onPressed: _zoomOut,
                ),
                IconButton(
                  icon: Icon(Icons.my_location),
                  onPressed: _recenterMap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _searchLocation(bool isStart) async {
    String address = isStart ? _startController.text : _endController.text;

    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        setState(() {
          LatLng location = LatLng(locations[0].latitude, locations[0].longitude);
          if (isStart) {
            startLocation = location;
            markers.add(Marker(
              point: startLocation!,
              child: Icon(Icons.location_on, color: Colors.red, size: 40),
            ));
          } else {
            endLocation = location;
            markers.add(Marker(
              point: endLocation!,
              child: Icon(Icons.location_on, color: Colors.green, size: 40),
            ));
            _getRoutes();
          }
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _getRoutes() async {
    if (startLocation == null || endLocation == null) return;

    final response = await http.get(
      Uri.parse('https://api.openrouteservice.org/v2/directions/driving-car?api_key=YOUR_API_KEY&start=${startLocation!.longitude},${startLocation!.latitude}&end=${endLocation!.longitude},${endLocation!.latitude}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List route = data['features'][0]['geometry']['coordinates'];
      List<LatLng> points = route.map((point) => LatLng(point[1], point[0])).toList();

      setState(() {
        polylines.add(Polyline(
          points: points,
          strokeWidth: 4.0,
          color: Colors.blue,
        ));
      });

      await _getCrimeData(points);
    }
  }

  Future<void> _getCrimeData(List<LatLng> route) async {
    final String response = await rootBundle.loadString('assets/crime_data.json');
    final data = json.decode(response);
    List crimes = data['crimes'];

    int minCrimes = route.length;
    Polyline safestRoute = polylines.first;

    // Logic to find the route with the minimum number of crimes
    int crimeCount = 0;
    for (var crime in crimes) {
      LatLng crimeLocation = LatLng(crime['Latitude'], crime['Longitude']);
      for (var point in route) {
        if (_calculateDistance(crimeLocation, point) < 0.01) {
          crimeCount++;
        }
      }
    }

    if (crimeCount < minCrimes) {
      minCrimes = crimeCount;
      safestRoute = Polyline(
        points: route,
        strokeWidth: 4.0,
        color: Colors.green,
      );

      setState(() {
        polylines.clear();
        polylines.add(safestRoute);
      });
    }

    await _addPoliceStations();
  }

  Future<void> _addPoliceStations() async {
    try {
      final String response = await rootBundle.loadString('assets/police_station.json');
      final data = json.decode(response);
      List policeStations = data['stations'];

      setState(() {
        for (var station in policeStations) {
          markers.add(Marker(
            point: LatLng(station['Latitude'], station['Longitude']),
            child: Icon(
              Icons.local_police,
              color: Color(0xFF000080), // Navy blue color
              size: 40,
            ),
          ));
        }
      });
    } catch (e) {
      print("Error loading police stations: $e");
    }
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    double lat1 = point1.latitude;
    double lon1 = point1.longitude;
    double lat2 = point2.latitude;
    double lon2 = point2.longitude;

    const p = 0.017453292519943295;
    final c = 0.5 - cos((lat2 - lat1) * p) / 2 + cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(c));
  }

  void _zoomIn() {
    final currentZoom = mapController.zoom;
    mapController.move(mapController.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = mapController.zoom;
    mapController.move(mapController.center, currentZoom - 1);
  }

  void _recenterMap() {
    if (startLocation != null) {
      mapController.move(startLocation!, mapController.zoom);
    }
  }
}
