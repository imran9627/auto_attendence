import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/authentication.dart';
import 'teach_tab1_page.dart';
import 'teach_tab2_page.dart';

class TeacherHomePage extends StatefulWidget {
  TeacherHomePage(
      {Key? key,
      required this.auth,
      required this.userId,
      required this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;

  final String userId;

  @override
  State<StatefulWidget> createState() => new _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  //final FirebaseDatabase _database = FirebaseDatabase.instance;

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.arrow_drop_down),
                  text: "Take Attendance",
                ),
                Tab(icon: Icon(Icons.book), text: "View Records"),
              ],
            ),
            title: Text(
              ' Welcome Teacher',
              style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.pinkAccent,
            actions: <Widget>[
              ElevatedButton(
                  child: new Text('Logout',
                      style: new TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  onPressed: signOut),
            ],
          ),
          body: TabBarView(
            children: [
              TeacherBasicPage(),
              TeacherBasicSecPage(),
            ],
          ),
        ),
      ),
    );
  }
}
