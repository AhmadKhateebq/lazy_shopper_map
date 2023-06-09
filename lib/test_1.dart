import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

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
  final LatLng _initialPosition = const LatLng(31.9753133, 35.1960417);

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
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue), // Set default marker icon
      );

      markers.add(marker);
    }

    return markers;
  }

  Future<void> _getUserLocation() async {
    final permissionStatus = await Permission.locationWhenInUse.request();

    if (permissionStatus.isGranted) {
      try {
        final geolocator.Position position =
            await geolocator.Geolocator.getCurrentPosition(
          desiredAccuracy: geolocator.LocationAccuracy.high,
        );

        print(
            'User Location - Latitude: ${position.latitude}, Longitude: ${position.longitude}');
      } catch (e) {
        print('Failed to get location: $e');
      }
    } else if (permissionStatus.isDenied) {
      print('Location permission is denied by the user.');
      // Display an error message or prompt the user to grant location permissions
    } else if (permissionStatus.isPermanentlyDenied) {
      print(
          'Location permission is permanently denied. Redirect the user to app settings.');
      // Display an error message or redirect the user to app settings
    }
  }

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    final frameInfo = await codec.getNextFrame();
    final image = frameInfo.image;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<BitmapDescriptor> _createCustomIcon() async {
    final Uint8List markerIconBytes =
        await _getBytesFromAsset('assets/icons/supermarket_icon.png', 100);

    return BitmapDescriptor.fromBytes(markerIconBytes);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  BitmapDescriptor? myIcon;

  @override
  void initState() {
    _createCustomIcon().then((BitmapDescriptor value) {
      setState(() {
        myIcon = value;
      });
    });
    super.initState();
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
          _getUserLocation(); // Get user location when map is created
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _createMarkers(),
      ),
    );
  }
}
