import "package:cloud_firestore/cloud_firestore.dart";
import 'package:flutter/material.dart';

import '../services/authentication.dart';

class TeacherLogin extends StatefulWidget {
  const TeacherLogin(
      {super.key, required this.auth, required this.loginCallback});

  final BaseAuth auth;
  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => _TeacherLoginState();
}

class _TeacherLoginState extends State<TeacherLogin> {
  final _formKey = GlobalKey<FormState>();

  late String _email;
  late String _password;
  late String _errorMessage;

  late bool _isLoading;

  // Check if form is valid before perform login or signup
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void validateAndSubmit() async {
    if (validateAndSave()) {
      setState(() {
        _errorMessage = "";
        _isLoading = true;
      });
      String userId = "";
      try {
        userId = await widget.auth.signIn(_email, _password);
        var result = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        print(result['role']);
        if (result['role'] == "student") {
          throw Exception("Only Teachers can login");
        }
        print('Signed in: $userId');
        setState(() {
          _isLoading = false;
        });

        if (userId.isNotEmpty && userId != null) {
          widget.loginCallback();
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
          _formKey.currentState!.reset();
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        //_errorMessage = e.message;
        // _formKey.currentState!.reset();
      });
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  void resetForm() {
    _formKey.currentState!.reset();
    _errorMessage = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text(
            'Login Here',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: Stack(
          children: <Widget>[
            _showForm(),
            _showCircularProgress(),
          ],
        ));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return const SizedBox(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget _showForm() {
    return Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              showLogo(),
              showEmailInput(),
              showPasswordInput(),
              showPrimaryButton(),
              showErrorMessage(),
            ],
          ),
        ));
  }

  Widget showErrorMessage() {
    if (_errorMessage.isNotEmpty && _errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Text(
            _errorMessage,
            style: const TextStyle(
                fontSize: 13.0,
                color: Colors.red,
                height: 1.0,
                fontWeight: FontWeight.w300),
          ),
        ),
      );
    } else {
      return Container(
        height: 0.0,
      );
    }
  }

  Widget showLogo() {
    return Hero(
      tag: 'hero',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 100.0,
          child: Image.asset('assets/Teacher.png'),
        ),
      ),
    );
  }

  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: const InputDecoration(
            hintText: 'Email',
            icon: Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) => value!.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value!.trim(),
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: const InputDecoration(
            hintText: 'Password',
            icon: Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) =>
            value!.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value!.trim(),
      ),
    );
  }

  Widget showPrimaryButton() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: ElevatedButton(
            // elevation: 5.0,
            // shape: new RoundedRectangleBorder(
            //     borderRadius: new BorderRadius.circular(30.0)),
            // color: Colors.blueAccent,
            onPressed: validateAndSubmit,
            // elevation: 5.0,
            // shape: new RoundedRectangleBorder(
            //     borderRadius: new BorderRadius.circular(30.0)),
            // color: Colors.blueAccent,
            child: const Text('Login',
                style: TextStyle(fontSize: 20.0, color: Colors.white)),
          ),
        ));
  }
}
