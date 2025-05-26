import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/location_service.dart';
import 'drawer_screen.dart';
import 'function_screen.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _userLocation = const LatLng(10.640739, 122.968956);
  final List<Marker> _markers = [];

  Future<void> _getUserLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied")),
      );
      return;
    }

    Position? position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
      _markers.clear();
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Location: ${position.latitude}, ${position.longitude}"),
      ),
    );
    }

  Future<void> _uploadCoordinates() async {
    final url = Uri.parse("https://autolink.fun/api/upload_loc.php");
    final response = await http.post(
      url,
      body: {
        "latitude": _userLocation.latitude.toString(),
        "longitude": _userLocation.longitude.toString(),
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Coordinates uploaded successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload coordinates.")),
      );
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
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              TileLayer(
                tileProvider: CancellableNetworkTileProvider(),
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    onPressed: _getUserLocation,
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.location_on, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DrawerScreen()),
                      );
                    },
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.home, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    onPressed: _uploadCoordinates,
                    backgroundColor: Colors.orange,
                    child: const Icon(Icons.upload, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
