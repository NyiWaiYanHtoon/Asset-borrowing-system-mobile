// ignore_for_file: prefer_const_constructors

import 'package:asset_borrowing_system_mobile/common_pages/config.dart';
import 'package:asset_borrowing_system_mobile/student/Student.dart';
import 'package:asset_borrowing_system_mobile/components/global.dart';
import 'package:asset_borrowing_system_mobile/components/input.dart';
import 'package:asset_borrowing_system_mobile/common_pages/register.dart';
import 'package:asset_borrowing_system_mobile/lecturer/Lecturer.dart';
import 'package:asset_borrowing_system_mobile/staff/Staff.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isPasswordVisible = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController pswController = TextEditingController();
  Map<String, dynamic> user={};

  void initState(){
    super.initState();
    checkLoginStatus();    
  }
  Future<void> checkLoginStatus() async {
    final retrievedUser = await retrieveData();
    setState(() {
      user = retrievedUser;
    });
    if(user!["role"]!=null){
      Widget destination = Student();
      if (user!['role'] == 1) {
        destination = Student();
      } else if (user!['role'] == 2) {
        destination = Lecturer();
      } else if (user!['role'] == 3) {
        destination = Staff();
      }
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => destination));
    }
  }

  void Login(email, psw) async {
    Map user = {
      "email": email,
      "psw": psw,
    };
    final Uri _uri = Uri.parse('http://${Config.getServerPath()}/login');
    http.Response response = await http.post(_uri, body: user);
    if (response.statusCode == 200) {
      Map<String, dynamic> userinfo = jsonDecode(response.body);
      Widget destination = Student();
      if (userinfo['role'] == 1) {
        destination = Student();
      } else if (userinfo['role'] == 2) {
        destination = Lecturer();
      } else if (userinfo['role'] == 3) {
        destination = Staff();
      }
      String? token = userinfo['token'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (token != null){
        await prefs.setString('jwt_token', token);
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          getErrorSnackbar(response.body),
        );
      }
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => destination));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        getErrorSnackbar(response.body),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            //Login image
            height: 290,
            child: Image.asset(
              'images/LoginImg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Quick Access to Your Assets!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  textInput(
                    label: "Email Address",
                    controller: emailController,
                  ),
                  pswInput(
                    label: "Password",
                    controller: pswController,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: const Color(0xFF003366),
                        foregroundColor: Colors.white),
                    onPressed: () {
                      Login(emailController.text, pswController.text);
                    },
                    child: const Text(
                      'Login',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const orDivider(),
                  const SizedBox(height: 24),
                  const googleSignup(),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EnterEmailPage()),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?"),
                        Text(
                          "Sign up",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
