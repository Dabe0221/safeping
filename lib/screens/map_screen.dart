import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/location_service.dart';
import 'drawer_screen.dart';
import 'function_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _userLocation = const LatLng(10.640739, 122.968956);
  final List<Marker> _markers = [];

  void _getUserLocation() async {
    Position? position = await LocationService.getCurrentPosition();
    if (position != null) {
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _markers.add(
          Marker(
            point: _userLocation,
            width: 50,
            height: 50,
            child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
          ),
        );
        _mapController.move(_userLocation, 15);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerScreen(),
      appBar: AppBar(title: const Text("Map Screen")),
      backgroundColor: const Color(0xFF651FFF),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation,
              initialZoom: 5.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: _markers.toList(), // Convert to list if needed
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _getUserLocation,
                  child: const Text("Tag Location"),
                ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FunctionScreen()),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home, color: Colors.purple),
                  SizedBox(width: 8),
                  Text("Home"),
                ],
              ),
            ),

          ]
            ),
          )
        ],
      ),
    );
  }
}
