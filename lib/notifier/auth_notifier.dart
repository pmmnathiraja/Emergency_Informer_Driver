import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthNotifier with ChangeNotifier {

  User _user;
  User get user => FirebaseAuth.instance.currentUser;

  void setUser(User user) async{
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }
}
