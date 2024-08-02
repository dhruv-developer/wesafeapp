import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenStreetMap Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();
  LatLng? startLocation;
  LatLng? endLocation;
  List<LatLng> routePoints = [];
  List<Map<String, dynamic>> crimeData = [];
  final MapController mapController = MapController();
  final String apiKey = '5b3ce3597851110001cf62482a39f0c95dbd475a959f1725db3e6fcc'; // Replace with your OpenRouteService API key
  bool showCrimeMarkers = false; // Flag to control crime marker visibility

  Future<void> _findLocations() async {
    String startAddress = startController.text;
    String endAddress = endController.text;

    try {
      // Convert start address to latitude and longitude
      List<Location> startLocations = await locationFromAddress(startAddress);
      if (startLocations.isNotEmpty) {
        setState(() {
          startLocation = LatLng(startLocations.first.latitude, startLocations.first.longitude);
        });
      }

      // Convert end address to latitude and longitude
      List<Location> endLocations = await locationFromAddress(endAddress);
      if (endLocations.isNotEmpty) {
        setState(() {
          endLocation = LatLng(endLocations.first.latitude, endLocations.first.longitude);
        });
        await _fetchRoute(startLocation!, endLocation!);
      }
    } catch (e) {
      print('Error finding locations: $e');
    }
  }

  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    final String url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';

    try {
      final response = await http.get(Uri.parse(url));
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}'); // Debugging: Print the API response

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['features'] != null && data['features'].isNotEmpty) {
          // Extract route coordinates
          List<dynamic> coordinates = data['features'][0]['geometry']['coordinates'];

          // Transform coordinates into LatLng points
          List<LatLng> routePoints = coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();

          // Fetch crime data and adjust route
          crimeData = await _fetchCrimeData();
          List<LatLng> adjustedRoute = _adjustRouteBasedOnCrime(routePoints, crimeData);

          setState(() {
            this.routePoints = adjustedRoute;
          });
        } else {
          print('No route found in the API response');
        }
      } else {
        print('Failed to load route. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCrimeData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/crime_data.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      return List<Map<String, dynamic>>.from(jsonData);
    } catch (e) {
      print('Error loading crime data: $e');
      return [];
    }
  }

  List<LatLng> _adjustRouteBasedOnCrime(List<LatLng> routePoints, List<Map<String, dynamic>> crimeData) {
    // Placeholder logic to adjust route based on crime data
    // For simplicity, let's return the original route here.
    return routePoints;
  }

  void _zoomIn() {
    mapController.move(mapController.center, mapController.zoom + 1);
  }

  void _zoomOut() {
    mapController.move(mapController.center, mapController.zoom - 1);
  }

  void _recenter() {
    if (startLocation != null) {
      mapController.move(startLocation!, 13.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OpenStreetMap Example'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: startController,
              decoration: InputDecoration(
                labelText: 'Start Location',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: endController,
              decoration: InputDecoration(
                labelText: 'End Location',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _findLocations,
            child: Text('Find Route'),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: startLocation ?? LatLng(51.509865, -0.118092),
                    zoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    if (routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            strokeWidth: 4.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        if (startLocation != null)
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: startLocation!,
                            child: Container(
                              child: Icon(
                                Icons.pin_drop,
                                color: Colors.red,
                                size: 40.0,
                              ),
                            ),
                          ),
                        if (endLocation != null)
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: endLocation!,
                            child: Container(
                              child: Icon(
                                Icons.pin_drop,
                                color: Colors.green,
                                size: 40.0,
                              ),
                            ),
                          ),
                        // Add crime markers
                        if (showCrimeMarkers) ..._crimeMarkers,
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        onPressed: _zoomIn,
                        tooltip: 'Zoom In',
                        child: Icon(Icons.zoom_in),
                      ),
                      SizedBox(height: 16),
                      FloatingActionButton(
                        onPressed: _zoomOut,
                        tooltip: 'Zoom Out',
                        child: Icon(Icons.zoom_out),
                      ),
                      SizedBox(height: 16),
                      FloatingActionButton(
                        onPressed: _recenter,
                        tooltip: 'Recenter',
                        child: Icon(Icons.my_location),
                      ),
                      SizedBox(height: 16),
                      // Toggle button to show/hide crime markers
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            showCrimeMarkers = !showCrimeMarkers;
                          });
                        },
                        tooltip: showCrimeMarkers ? 'Hide Crime Markers' : 'Show Crime Markers',
                        child: Icon(showCrimeMarkers ? Icons.visibility_off : Icons.visibility),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> get _crimeMarkers {
    return crimeData.map((crime) {
      return Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(crime['Latitude'], crime['Longitude']),
        child: Container(
          child: Icon(
            Icons.warning,
            color: Colors.blue,
            size: 40.0,
          ),
        ),
      );
    }).toList();
  }
}
