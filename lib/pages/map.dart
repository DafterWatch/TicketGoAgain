import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final Set<Marker> _markers = Set();

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  late CameraPosition _ubicacionInicial = CameraPosition(
    target: LatLng(0, 0),
    zoom: 18,
  );
  @override
  Widget build(BuildContext context) {
    _getUbicacionActual();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Google Prueba Locations'),
          backgroundColor: Colors.blue[700],
        ),
        body: GoogleMap(
          compassEnabled: false,
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
          markers: _markers,
          mapType: MapType.satellite,
          initialCameraPosition: _ubicacionInicial,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
        /*floatingActionButton: FloatingActionButton.extended(
          onPressed: _getUbicacionActual,
          label: Text('Mi ubicacion!'),
          icon: Icon(Icons.directions_boat),
        ),*/
      ),
    );
  }

  Future<void> _getUbicacionActual() async {
    //objeto geolocator que obtendra la ubicaciionactual
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    Position positionActual = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    GoogleMapController controller = await _controller.future;

    controller.moveCamera(CameraUpdate.newLatLngZoom(
        LatLng(positionActual.latitude, positionActual.longitude), 18));
    _ubicacionInicial = CameraPosition(
      target: LatLng(positionActual.latitude, positionActual.longitude),
      zoom: 15,
    );
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('Ubicacion Actual'),
          position: LatLng(positionActual.latitude, positionActual.longitude),
          infoWindow: InfoWindow(
            title: 'Mi ubicacion',
            snippet: 'Esta es tu ubicacion actual',
          ),
        ),
      );
    });
  }
}
