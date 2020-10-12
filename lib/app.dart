import 'package:flutter/material.dart';
import 'package:driver/_routing/routes.dart';
import 'package:driver/_routing/router.dart' as router;
import 'package:driver/theme.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Social',
      debugShowCheckedModeBanner: false,
      theme: buildThemeData(),
      onGenerateRoute: router.generateRoute,
      initialRoute: landingViewRoute,
    );
  }
}
