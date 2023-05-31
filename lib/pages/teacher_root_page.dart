import 'package:aut_attendance/pages/teach_home_page.dart';
import 'package:aut_attendance/pages/teacher_login.dart';
import 'package:flutter/material.dart';

import '../services/authentication.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class TeacherRootPage extends StatefulWidget {
  const TeacherRootPage({super.key, required this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => _TeacherRootPageState();
}

class _TeacherRootPageState extends State<TeacherRootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user.uid;
        }
        authStatus =
            user.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  void loginCallback() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void logoutCallback() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Auth status $authStatus/////////////');
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return TeacherLogin(
          auth: widget.auth,
          loginCallback: loginCallback,
        );
      //buildWaitingScreen();
      case AuthStatus.NOT_LOGGED_IN:
        return TeacherLogin(
          auth: widget.auth,
          loginCallback: loginCallback,
        );
      case AuthStatus.LOGGED_IN:
        if (_userId.isNotEmpty && _userId != null) {
          return TeacherHomePage(
            userId: _userId,
            auth: widget.auth,
            logoutCallback: logoutCallback,
          );
        } else {
          return buildWaitingScreen();
        }
      default:
        return buildWaitingScreen();
    }
  }
}
