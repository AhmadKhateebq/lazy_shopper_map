import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'model/supermarket.dart';

void main() => runApp(const MyApp());
List<Supermarket> supermarkets = [
  Supermarket(
      name: 'Broaster chicken', locationX: 31.969790, locationY: 35.194734),
  Supermarket(
      name: 'Alto kitchens', locationX: 31.970856, locationY: 35.193350),
  // Add more supermarkets as needed
];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Interface',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GoogleMapPage(),
    );
  }
}

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({Key? key}) : super(key: key);

  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  late GoogleMapController _mapController;
  final LatLng _initialPosition = const LatLng(37.7749, -122.4194);

  Set<Marker> _createMarkers() {
    Set<Marker> markers = {};

    for (final supermarket in supermarkets) {
      final LatLng position =
          LatLng(supermarket.locationX, supermarket.locationY);

      final marker = Marker(
        markerId: MarkerId(supermarket.name),
        position: position,
        infoWindow: InfoWindow(
          title: supermarket.name,
        ),
      );

      markers.add(marker);
    }

    return markers;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Interface'),
      ),
      body: GoogleMap(
        initialCameraPosition:
            CameraPosition(target: _initialPosition, zoom: 14),
        onMapCreated: (controller) {
          _mapController = controller;
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _createMarkers(),
      ),
    );
  }
}
