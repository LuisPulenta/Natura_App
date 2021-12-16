import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:natura_app/models/token.dart';
import 'package:natura_app/models/user.dart';

class DireccionScreen extends StatefulWidget {
  final Token token;
  final User user;
  const DireccionScreen({required this.token, required this.user});

  @override
  _DireccionScreenState createState() => _DireccionScreenState();
}

class _DireccionScreenState extends State<DireccionScreen> {
  String _direccion = '';
  String _direccionError = '';
  bool _direccionShowError = false;
  TextEditingController _direccionController = TextEditingController();

  double latitud = 0;
  double longitud = 0;
  String direccion = '';
  final Set<Marker> _markers = {};
  MapType _defaultMapType = MapType.normal;
  Position position = Position(
      longitude: 0,
      latitude: 0,
      timestamp: null,
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);
  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(-31.4332373, -64.226344), zoom: 16.0);
  //static const LatLng _center = const LatLng(-31.4332373, -64.226344);

  LatLng _center = LatLng(0, 0);

  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPosition().then((value) => {
          _center = LatLng(position.latitude, position.longitude),
          _initialPosition = CameraPosition(target: _center, zoom: 16.0)
        });
  }

  Future _getPosition() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    latitud = position.latitude;
    longitud = position.longitude;
    direccion = placemarks[0].street.toString() +
        " - " +
        placemarks[0].locality.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dirección"),
      ),
      body: Container(
        child: Stack(children: <Widget>[
          GoogleMap(
            myLocationEnabled: false,
            initialCameraPosition: _initialPosition,
            onCameraMove: _onCameraMove,
            markers: _markers,
            mapType: _defaultMapType,
          ),
          Container(
            margin: EdgeInsets.only(top: 80, right: 10),
            alignment: Alignment.topRight,
            child: Column(children: <Widget>[
              FloatingActionButton(
                  child: Icon(Icons.layers),
                  elevation: 5,
                  backgroundColor: Color(0xfff4ab04),
                  onPressed: () {
                    _changeMapType();
                  }),
            ]),
          ),
          Center(
            child: Icon(
              Icons.my_location,
              color: Color(0xFFfc6c0c),
              size: 50,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _direccionController,
              decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'Dirección...',
                  labelText: 'Dirección',
                  errorText: _direccionShowError ? _direccionError : null,
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              onChanged: (value) {
                _direccion = value;
              },
            ),
          ),
        ]),
      ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on),
                  SizedBox(
                    width: 20,
                  ),
                  Text('Marcar'),
                ],
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return Color(0xFFe4540c);
                }),
              ),
              onPressed: () => _marcar(),
            ),
            ElevatedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save),
                  SizedBox(
                    width: 20,
                  ),
                  Text('Guardar'),
                ],
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return Color(0xFFe4540c);
                }),
              ),
              onPressed: () => _guardar(),
            ),
          ],
        ),
      ],
    );
  }

  void _onCameraMove(CameraPosition position) {
    _center = position.target;
  }

  void _marcar() async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(_center.latitude, _center.longitude);
    latitud = _center.latitude;
    longitud = _center.longitude;
    direccion = placemarks[0].street.toString() +
        " - " +
        placemarks[0].locality.toString();
    _direccionController.text = direccion;
    _markers.clear();
    _markers.add(Marker(
// This marker id can be anything that uniquely identifies each marker.
      markerId: MarkerId(_center.toString()),
      position: _center,
      infoWindow: InfoWindow(
        title: direccion,
        snippet: '',
      ),
      icon: BitmapDescriptor.defaultMarker,
    ));
    setState(() {});
  }

  void _changeMapType() {
    _defaultMapType = _defaultMapType == MapType.normal
        ? MapType.satellite
        : _defaultMapType == MapType.satellite
            ? MapType.hybrid
            : MapType.normal;
    setState(() {});
  }

  _guardar() {}
}
