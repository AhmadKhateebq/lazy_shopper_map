import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoogleMapController? _mapController;
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    final permissionStatus = await Permission.locationWhenInUse.request();

    if (permissionStatus.isGranted) {
      try {
        final geolocator.Position? position =
            await geolocator.Geolocator.getCurrentPosition(
          desiredAccuracy: geolocator.LocationAccuracy.high,
        );
        if (position != null) {
          setState(() {
            _userLocation = LatLng(position.latitude, position.longitude);
          });
          if (_mapController != null) {
            _mapController!
                .animateCamera(CameraUpdate.newLatLng(_userLocation!));
          }
        }
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

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('User Location'),
          elevation: 2,
        ),
        body: _buildMap(),
      ),
    );
  }

  Widget _buildMap() {
    if (_userLocation != null) {
      return GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _userLocation!,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('user_location'),
            position: _userLocation!,
          ),
        },
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
