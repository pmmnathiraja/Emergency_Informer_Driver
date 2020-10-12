import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/notifier/auth_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:driver/map/map_load.dart';
import 'package:driver/model/user.dart';
import 'package:driver/utils/colors.dart';
import 'package:driver/utils/utils.dart';
import 'package:provider/provider.dart';

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

class SignalLocationPage extends StatelessWidget {
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
            body: SignalDetect(),
          )),
    );
  }
}

class SignalDetect extends StatefulWidget {
  const SignalDetect({Key key}) : super(key: key);
  @override
  _SignalDetectState createState() => _SignalDetectState();
}

class _SignalDetectState extends State<SignalDetect> {
  AuthNotifier authNotifier;
  var userLocation;
  var initDistance = 1000.0;
  UserData userSet = UserData();
  String googleAPiKey = '/googleAPiKey/';
  var distance;

  @override
  Widget build(BuildContext context) {
    userLocation = Provider.of<UserLocation>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('location').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Container();
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }
              if (snapshot.data.docs != null) {
                snapshot.data.docs.map((DocumentSnapshot document) async {
                  final _driveCurrentLocation =
                      LatLng(userLocation?.latitude, userLocation?.longitude);

                  document.data().forEach((key, value) {
                    GeoPoint _userPosition = value;
                    final _userCurrentLocation =
                        LatLng(_userPosition.latitude, _userPosition.longitude);

                    distance = SphericalUtil.computeDistanceBetween(
                            _driveCurrentLocation, _userCurrentLocation) /
                        1000.0;
                    print('Distance between London and Paris is $distance km.');

                    if (distance < initDistance) {
                      initDistance = distance;
                      userSet.displayDriverName =
                          FirebaseAuth.instance.currentUser.displayName;
                      userSet.userLatitude = _userCurrentLocation.latitude;
                      userSet.userLongitude = _userCurrentLocation.longitude;
                      userSet.driverLatitude = userLocation?.latitude;
                      userSet.driverLongitude = userLocation?.longitude;
                      userSet.patientID = key;
                      //  patient_ID = value['name'];
                    }
                  });
                  await Future.delayed(Duration(seconds: 1));
                }).toList();
                if (initDistance <= 400) {
                  return Container(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                            top: 80.0,
                            bottom: 30.0,
                            left: 30.0,
                            right: 30.0,
                          ),
                          decoration: BoxDecoration(gradient: primaryGradient),
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 60.0,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7.0),
                                  border: Border.all(color: Colors.white),
                                  color: Colors.white,
                                ),
                                child: RaisedButton(
                                  elevation: 5.0,
                                  onPressed: () => {
//                                    updateFirebase(userSet),
                                    Future.delayed(Duration(seconds: 1)),
                                    Future(() {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DriverLocationPage(userSet),
                                            ));
                                      });
                                    }),
                                  },
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),
                                  child: Text(
                                    'Emergency',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Container(
                              height: 500.0,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AvailableImages.homePage,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                  //   });
                }

                return Container(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 70.0),
                        decoration: BoxDecoration(gradient: primaryGradient),
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 200.0,
                              width: 200.0,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AvailableImages.appLogo,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Column(
                              children: <Widget>[
                                Text(
                                  'Emergency',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 50.0,
                                  ),
                                ),
                                Text(
                                  "Informer",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Container(
                            height: 400.0,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AvailableImages.homePage,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              } else {
                return Container(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 70.0),
                        decoration: BoxDecoration(gradient: primaryGradient),
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 200.0,
                              width: 200.0,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AvailableImages.appLogo,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Column(
                              children: <Widget>[
                                Text(
                                  'Emergency',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 50.0,
                                  ),
                                ),
                                Text(
                                  "Informer",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Container(
                            height: 400.0,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AvailableImages.homePage,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }

  void updateFirebase(UserData userDetails) {
    FirebaseFirestore.instance
        .collection("RequestAccepted")
        .doc(userDetails.patientID)
        .set({
      'User_Location':
          GeoPoint(userDetails.driverLatitude, userDetails.driverLongitude)
    }).then((_) {
      FirebaseFirestore.instance
          .collection("RequestPool")
          .doc(userDetails.patientID)
          .delete()
          .then((_) {
        Future(() {
          Future.delayed(Duration(seconds: 1));
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DriverLocationPage(userDetails),
                ));
          });
        });
      });
    });
  }
}
