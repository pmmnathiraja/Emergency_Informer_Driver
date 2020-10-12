import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:driver/_routing/routes.dart';
import 'package:driver/views/landing.dart';
import 'package:driver/views/register.dart';
import 'package:driver/views/reset_password.dart';
import 'package:driver/map/map_load.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case landingViewRoute:
      return MaterialPageRoute(builder: (context) => LandingPage());
    case registerViewRoute:
      return MaterialPageRoute(builder: (context) => RegisterPage());
    case resetPasswordViewRoute:
      return MaterialPageRoute(builder: (context) => ResetPasswordPage());
//    case mapViewRoute:
//      return MaterialPageRoute(builder: (context) => MapViewMain());
//    case FeedViewRoute:
//      return MaterialPageRoute(builder: (context) => StorageUploadFeed());
//    case chatDetailsViewRoute:
//      return MaterialPageRoute(builder: (context) => ChatDetailsPage(userId: settings.arguments));
//    case userDetailsViewRoute:
//      return MaterialPageRoute(builder: (context) => UserDetailsPage(userId: settings.arguments));
      break;
    default:
      return MaterialPageRoute(builder: (context) => LandingPage());
  }
}
