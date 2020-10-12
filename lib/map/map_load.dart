import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/model/user.dart';
import 'package:driver/notifier/auth_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:driver/map/reachhospital.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:async';

class LocationService {
  UserLocation _currentLocation;

  var location = Location();
  StreamController<UserLocation> _locationController =
      StreamController<UserLocation>();

  Stream<UserLocation> get locationStream => _locationController.stream;

  LocationService() {
    // Request permission to use location
    location.requestPermission().then((permissionStatus) {
      if (permissionStatus == PermissionStatus.granted) {
        // If granted listen to the onLocationChanged stream and emit over our controller
        location.onLocationChanged.listen((locationData) {
          if (locationData != null) {
            _locationController.add(UserLocation(
              latitude: locationData.latitude,
              longitude: locationData.longitude,
            ));
          }
        });
      }
    });
  }

  Future<UserLocation> getLocation() async {
    try {
      var userLocation = await location.getLocation();
      _currentLocation = UserLocation(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
      );
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }
    return _currentLocation;
  }
}

class UserLocation {
  final double latitude;
  final double longitude;

  UserLocation({this.latitude, this.longitude});
}

class DriverLocationPage extends StatelessWidget {
  DriverLocationPage(this.userPersonalData) : super();
  final UserData userPersonalData;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserLocation>(
      create: (context) => LocationService().locationStream,
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: const Text('                          Your Route'),
              backgroundColor: Colors.indigo,
            ),
            body: MapViewMain(userPersonalData),
          )),
    );
  }
}

class MapViewMain extends StatefulWidget {
  const MapViewMain(this.userPersonalData, {Key key}) : super(key: key);
  final UserData userPersonalData;
  @override
  _MapViewMainState createState() => _MapViewMainState();
}

class _MapViewMainState extends State<MapViewMain> {
  var userLocation;
  User _firebaseUser = FirebaseAuth.instance.currentUser;
  GoogleMapController mapController;
  double _originLatitude, _originLongitude;
  double _destLatitude, _destLongitude;
  double _initLatitude = 0, _initLongitude = 0;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polyLines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = '/googleAPiKey/';
  AuthNotifier authNotifier;
  int informEmergency = 0;
  String _textString = "Inform Emergency";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userLocation = Provider.of<UserLocation>(context);

    return Container(
      child: StreamBuilder(
        builder: (context, snapshot) {
          if (!snapshot.hasError) {
            if ((userLocation?.latitude != null &&
                    userLocation?.longitude != null) &&
                (userLocation?.latitude != _initLatitude ||
                    userLocation?.longitude != _initLongitude)) {
              _initLatitude = userLocation?.latitude;
              _initLongitude = userLocation?.longitude;
              _initiateLine();
            }
            return Stack(
              children: <Widget>[
                userLocation?.latitude == null ||
                        userLocation?.longitude == null
                    ? Container()
                    : GoogleMap(
                        //onMapCreated: _onMapCreatedFirst,
                        initialCameraPosition: CameraPosition(
                          target: const LatLng(6.5212402, 3.3679965),
                          zoom: 2,
                        ),
                        myLocationEnabled: true,
                        tiltGesturesEnabled: true,
                        compassEnabled: true,
                        scrollGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                        onMapCreated: _onMapCreated,
                        markers: Set<Marker>.of(markers.values),
                        polylines: Set<Polyline>.of(polyLines.values),
                      ),
                Positioned(
                  bottom: 10,
                  left: 100,
                  child: FloatingActionButton.extended(
                    onPressed: () => {
                      goToHospital(widget.userPersonalData),
//                      Future(() {
//                        WidgetsBinding.instance.addPostFrameCallback((_) {
//                          Navigator.push(
//                              context,
//                              MaterialPageRoute(
//                                builder: (context) => ReachHospitalPage(),
//                              ));
//                        });
//                      }),
                    },
                    label: Text('Go to the Hospital'),
                    icon: Icon(Icons.info),
                    backgroundColor: Colors.pink,
                  ),
                ),
                //
              ],
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  _initiateLine() {
    _destLatitude = widget.userPersonalData.userLatitude;
    _destLongitude = widget.userPersonalData.userLongitude;
    _originLatitude = userLocation?.latitude;
    _originLongitude = userLocation?.longitude;

    markers.clear();

    _addMarker(
      LatLng(_destLatitude, _destLongitude),
      "destination",
      BitmapDescriptor.defaultMarkerWithHue(10),
    );
    print("draw polyline");
    FirebaseFirestore.instance
        .collection("RequestAccepted")
        .doc(widget.userPersonalData.patientID)
        .set({
      'User_Location': GeoPoint(userLocation?.latitude, userLocation?.longitude)
    }).then((_) {
      _getPolyline();
    });
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine() {
    polyLines.clear();
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polyLines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "/googleAPiKey/",
      PointLatLng(_originLatitude, _originLongitude),
      PointLatLng(_destLatitude, _destLongitude),
    );
    polylineCoordinates.clear();
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  void goToHospital(UserData userDetails) {
    FirebaseFirestore.instance
        .collection("RequestAccepted")
        .doc(userDetails.patientID)
        .delete()
        .then((_) {
      Future(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReachHospitalPage(),
              ));
        });
      });
    });
  }
}
