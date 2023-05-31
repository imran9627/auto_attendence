import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/authentication.dart';

class TeacherBasicSecPage extends StatefulWidget {
  const TeacherBasicSecPage(
      {Key? key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth? auth;
  final VoidCallback? logoutCallback;

  final String? userId;

  @override
  State<StatefulWidget> createState() => _TeacherBasicSecPageState();
}

class _TeacherBasicSecPageState extends State<TeacherBasicSecPage> {
  //final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

  //final _textEditingController = TextEditingController();
  //bool _isEmailVerified = false;
  late String subject;
  late String month;
  late String year;
  late String str;
  String userId = '';
  int shows = 0;

  bool validateAndSave() {
    final form = _formKey2.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  void initState() {
    userId = widget.userId!;
    super.initState();
    //_checkEmailVerification();
  }

  @override
  Widget build(BuildContext context) {
    if (shows == 0) {
      return showEntryPage();
    } else {
      return showDataPage();
    }
  }

  Widget showEntryPage() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          //resizeToAvoidBottomPadding: false,
          body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    enterDetails(),
                    formInput(),
                    GestureDetector(
                      onTap: () {
                        if (validateAndSave()) {
                          setState(() {
                            shows = 1;
                          });
                          //showDataPage();
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(70),
                        width: 300,
                        height: 40,
                        //color:Colors.pink,
                        decoration: const BoxDecoration(
                            color: Colors.pink,
                            shape: BoxShape.rectangle,
                            //borderRadius: BorderRadius.circular(10),
                            borderRadius:
                                BorderRadius.all(Radius.circular(25))),
                        child: const Center(
                          child: Text(
                            'View',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  Widget formInput() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey2,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            subjCodeInput(),
            dateInput(),
            yearInput(),
          ],
        ),
      ),
    );
  }

  Widget enterDetails() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
        width: 280,
        height: 50,
        alignment: const Alignment(80, 30),
        decoration: const BoxDecoration(
          color: Colors.pink,
          shape: BoxShape.rectangle,
          //borderRadius: BorderRadius.circular(12),
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(20), topLeft: Radius.circular(20)),
        ),
        child: const Center(
          child: Text(
            'Enter Details',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }

  Widget subjCodeInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 5.0),
      child: TextFormField(
        maxLines: 1,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          hintText: 'Enter Subject',
        ),
        keyboardType: TextInputType.text,
        autofocus: false,
        validator: (value) => value!.isEmpty ? 'Enter Subject first' : null,
        onSaved: (value) => subject = value!.trim(),
      ),
    );
  }

  Widget dateInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        decoration: const InputDecoration(
          hintText: 'Enter Month',
        ),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.datetime,
        autofocus: false,
        validator: (value) => value!.isEmpty ? 'Enter Month first' : null,
        onSaved: (value) => month = value!.trim(),
      ),
    );
  }

  Widget yearInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        decoration: const InputDecoration(
          hintText: 'Enter Year',
        ),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        autofocus: false,
        validator: (value) => value!.isEmpty ? 'Enter Year first' : null,
        onSaved: (value) => year = value!.trim(),
      ),
    );
  }

  Widget showDataPage() {
    //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => TeachDetails()));
    return Scaffold(
      body: Container(
        child: FutureBuilder(
            future: getData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Scaffold(
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      ),
                      const SizedBox(height: 10),
                      const Text('Loading'),
                    ],
                  ),
                );
                //return Center(child: Container(child: Text('Loading Data',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),));
              }

              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    DataTable(
                        sortColumnIndex: 0,
                        sortAscending: true,
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Attended'), numeric: true)
                        ],
                        rows: snapshot.data.entries.map<DataRow>((entry) {
                          return DataRow(cells: [
                            DataCell(Text(entry.key)),
                            DataCell(Text(entry.value.toString())),
                          ]);
                        }).toList()),
                    Center(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: ElevatedButton(
                            // color: Colors.indigo,
                            //   textColor: Colors.white,
                            onPressed: () {
                              setState(() {
                                shows = 0;
                              });
                            },
                            child: const Text('Return')),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }

  Future<Map> getData() async {
    var attendance = new Map();
    num subCount = 0;
    String queryMonth = month.toString() + '.' + year.toString();
    var j1;
    var users = await FirebaseFirestore.instance.collection('users').get();
    var idList = users.docs;
    for (int i = 0; i < idList.length; i++) {
      if (idList[i].data()['role'] == 'student') {
        var y = await FirebaseFirestore.instance
            .collection('users')
            .doc(idList[i].id)
            .collection(subject)
            .doc(queryMonth)
            .get();
        for (int j = 1; j <= 30; j++) {
          if (j < 10) {
            j1 = j.toString().padLeft(2, '0');
          } else {
            j1 = j.toString();
          }
          try {
            subCount += y.data()![j1]['count'];
          } catch (e) {
            continue;
          }
        }
        attendance[idList[i].data()['Name']] = subCount;
        subCount = 0;
      }
    }
    //print(attendance);
    return attendance;
  }
}
