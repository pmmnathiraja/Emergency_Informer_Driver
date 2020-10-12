import 'dart:async';

import 'package:flutter/material.dart';
import 'package:driver/loginInit.dart';
import 'package:driver/model/user.dart';
import 'package:driver/utils/colors.dart';
import 'package:driver/utils/utils.dart';

class ReachHospitalPage extends StatefulWidget {

  @override
  _ReachHospitalPageState createState() => _ReachHospitalPageState();
}

class _ReachHospitalPageState extends State<ReachHospitalPage> {
  UserData userSet = UserData();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
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
                        onPressed: () {
                          Future(() {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginInit(),
                                  ));
                            });
                          });
                        },
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        child: Text(
                          'Reached to the Hospital',
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
        ),
      ),
    );
  }
}
