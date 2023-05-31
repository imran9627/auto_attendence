import "package:cloud_firestore/cloud_firestore.dart";
import 'package:encrypt/encrypt.dart' as ency;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/authentication.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage(
      {Key? key,
      required this.auth,
      required this.userId,
      required this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  //final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String barcode = "";
  String status = "";

  //final _textEditingController = TextEditingController();

  //bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();

    //_checkEmailVerification();
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Smart Attendance'),
          backgroundColor: Colors.deepOrange,
          actions: <Widget>[
            ElevatedButton(
                onPressed: signOut,
                child: const Text('Logout',
                    style: TextStyle(fontSize: 20.0, color: Colors.white)))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
                    width: 400,
                    height: 60,
                    alignment: const Alignment(100, 20),
                    decoration: const BoxDecoration(
                      color: Colors.deepOrangeAccent,
                      shape: BoxShape.rectangle,
                      //borderRadius: BorderRadius.circular(15),
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(25),
                          topLeft: Radius.circular(25)),
                    ),
                    child: const Center(
                      child: Text(
                        'Hello Student',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                  margin: const EdgeInsets.only(top: 40, bottom: 40),
                  width: 320.0,
                  height: 380.0,
                  //alignment: Alignment(100, 20),
                  decoration: const BoxDecoration(
                    //color: Colors.lightBlue[50],
                    shape: BoxShape.rectangle,
                    //borderRadius: BorderRadius.circular(25),
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(35),
                        topLeft: Radius.circular(35)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            qrCodeScan();
                          },
                          child: Container(
                            // margin: new  EdgeInsets.only(left: 10,right:10,top:10,bottom:30),
                            padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
                            width: 200,
                            margin: const EdgeInsets.only(top: 60, bottom: 10),
                            height: 80,
                            alignment: const Alignment(50, 50),
                            decoration: const BoxDecoration(
                              color: Colors.deepOrange,
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.all(Radius.elliptical(20, 30)),
                              //borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Center(
                              child: Text(
                                '  Scan QR \n     Code',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 200),
                        Text(status),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future qrCodeScan() async {
    //String barcode = await scanner.scan();
    final key = ency.Key.fromUtf8('JingalalahuhuJingalalahuhuJingal');
    final iv = ency.IV.fromLength(16);
    final encrypter = ency.Encrypter(ency.AES(key));
    final decryptedQR =
        encrypter.decrypt(ency.Encrypted.from64(barcode), iv: iv);
    print('BARCODE$decryptedQR');
    setState(() => barcode = decryptedQR);
    var a = updateDatabase();
  }

  Future<void> updateDatabase() async {
    final firestoreInstance = FirebaseFirestore.instance;
    var docs = FirebaseFirestore.instance.doc('Users/$this.userId');
    var qrDetails = barcode.split('/');
    var classname = qrDetails[0];
    var dates = qrDetails[1].split('.');
    var day = dates[0];
    var date = '${dates[1]}.${dates[2]}';
    var check = qrDetails[2];
    var secretCode = qrDetails[3];
    var updatedCount = 0;
    var updatedCodes = [];
    var codeExists = 0;
    var teacherCodeExists = 0;
    var exists = 0;
    //print(docs);
    var teacherUID = qrDetails[4];
    var firebaseUser = FirebaseAuth.instance.currentUser!;
    final CollectionReference monthsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .collection(classname);
    var monthsDocs = await FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseUser.uid)
        .collection(classname)
        .get();

    var months = monthsDocs.docs;

    for (int i = 0; i < months.length; i++) {
      if (date == months[i].id) {
        exists = 1;
        break;
      }
    }

    if (exists == 0) await monthsRef.doc(date).set({});

    var data = await FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseUser.uid)
        .collection(classname)
        .doc(date)
        .get();

    print('TEACHER UID :$teacherUID');

    var teacherData = await FirebaseFirestore.instance
        .collection("users")
        .doc(teacherUID)
        .collection(classname)
        .doc(date)
        .get();

    try {
      for (int i = 0; i < teacherData[day]['codes'].length; i++) {
        print(teacherData[day]['codes'][i]);
        if (teacherData[day]['codes'][i] == secretCode) {
          teacherCodeExists = 1;
          break;
        }
      }
    } catch (e) {
      print('Teacher Code exists caught');
    }

    try {
      updatedCount = data[day]['count'] + 1;
    } catch (e) {
      updatedCount = 1;
    }

    try {
      for (int i = 0; i < data[day]['codes'].length; i++) {
        print(data[day]['codes'][i]);
        if (data[day]['codes'][i] == secretCode) {
          codeExists = 1;
          break;
        }
      }
    } catch (e) {
      print('Code exists caught');
    }
    print('CODE EXISTS$codeExists');
    if (int.parse(check) < updatedCount) {
      setState(() {
        status = 'Attendance limit exceeded';
      });
    } else if (codeExists == 1) {
      setState(() {
        status = 'Reuse of code detected';
      });
    } else if (teacherCodeExists == 0) {
      setState(() {
        status = 'Invalid Code,not in database';
      });
    } else {
      try {
        updatedCodes = data[day]['codes'] + [secretCode];
      } catch (e) {
        updatedCodes = [secretCode];
      }

      try {
        firestoreInstance
            .collection("users")
            .doc(firebaseUser.uid)
            .collection(classname)
            .doc(date)
            .update({
          "$day.check": int.parse(check),
          "$day.count": updatedCount,
          "$day.codes": updatedCodes
        }).then((_) {
          setState(() {
            status = 'Update Successful';
          });
        });
      } catch (e) {
        setState(() {
          status = '${status}Update Fail';
        });
        print(e.toString());
      }
    }
  }
}
