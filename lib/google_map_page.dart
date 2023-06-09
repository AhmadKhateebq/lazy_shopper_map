import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

import 'dummy_data/not_contain_product.dart';
import 'model/product_data.dart';
import 'model/supermarket_data.dart';
import 'dummy_data/supermarket_list.dart';

void main() => runApp(const MyApp());

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

List<Widget> _buildDoNotContainList() {
  List<Product> doNotContainProducts = doNotContain;

  return [
    const SizedBox(height: 16),
    Text(
      'Do Not Contain:',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    const SizedBox(height: 8),
    SingleChildScrollView(
      child: Column(
        children: doNotContainProducts.map((product) {
          return ListTile(
            title: Text(product.name),
            subtitle: Text(product.description),
          );
        }).toList(),
      ),
    ),
  ];
}

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({Key? key}) : super(key: key);

  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  bool _isBottomSheetOpen = false;
  void _openBottomSheet(Supermarket_data supermarket) {
    setState(() {
      _isBottomSheetOpen = true;
    });

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize:
              0.3, // Initial height of the sheet (0.3 means 30% of the screen)
          maxChildSize:
              0.8, // Maximum height of the sheet (1.0 means full screen)
          minChildSize:
              0.1, // Minimum height of the sheet (0.1 means 10% of the screen)
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supermarket.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Location: ${supermarket.locationX}, ${supermarket.locationY}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Contain Percentage: ${supermarket.containPercentage}%',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Original Items Size: ${supermarket.originalItemsSize}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Containing Size: ${supermarket.containingSize}',
                        style: TextStyle(fontSize: 16),
                      ),
                      ..._buildDoNotContainList(),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      setState(() {
        _isBottomSheetOpen = false;
      });
    });
  }

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
        icon: myIcon, // Set default marker icon
        onTap: () {
          _openBottomSheet(supermarket);
          ;
        },
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

  BitmapDescriptor myIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);

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
