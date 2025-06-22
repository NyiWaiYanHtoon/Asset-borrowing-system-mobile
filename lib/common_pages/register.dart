// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:convert';
import 'package:asset_borrowing_system_mobile/common_pages/config.dart';
import 'package:asset_borrowing_system_mobile/common_pages/login.dart';
import 'package:asset_borrowing_system_mobile/components/global.dart';
import 'package:asset_borrowing_system_mobile/components/input.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';

//Enter email page
class EnterEmailPage extends StatefulWidget {
  const EnterEmailPage({super.key});

  @override
  State<EnterEmailPage> createState() => _EnterEmailPageState();
}

class _EnterEmailPageState extends State<EnterEmailPage> {
  TextEditingController inputEmail = TextEditingController();

  void sendOTP(String email) async {
    final Uri _uri = Uri.parse("http://${Config.getServerPath()}/sendOTP");
    http.Response response = await http.post(_uri, body: {
      "email": email,
    });
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(getErrorSnackbar(response.body));
    } else {
      Map<String, dynamic> otpInfo = jsonDecode(response.body);
      SharedPreferences pref = await SharedPreferences.getInstance();
      if (otpInfo != null) {
        pref.setString("hash", otpInfo['hash']);
        pref.setString("expires", otpInfo['expires'].toString());
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EnterOTPPage(email: email)),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(getErrorSnackbar("Server Error"));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                "images/enter-email.jpg",
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Login With Email",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Please enter your email and we will send you email to verify",
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              child: textInput(label: "Email", controller: inputEmail),
            ),
            ElevatedButton(
              onPressed: () {
                //send Email
                sendOTP(inputEmail.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}

class EnterOTPPage extends StatefulWidget {
  String email;
  EnterOTPPage({super.key, required this.email});

  @override
  State<EnterOTPPage> createState() => _EnterOTPPageState();
}

class _EnterOTPPageState extends State<EnterOTPPage> {
  TextEditingController inputOTP = TextEditingController();

  void verifyOTP(String otp) async {
    final Uri _uri = Uri.parse("http://${Config.getServerPath()}/verifyOTP");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> verifyInfo = {
      "hash": prefs.getString("hash"),
      "expires": prefs.getString("expires"),
      "email": widget.email,
      "otp": otp,
    };
    http.Response response = await http.post(_uri, body: verifyInfo);
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(getErrorSnackbar(response.body));
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => RegisterPage(email: widget.email)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                "images/enter-otp.webp",
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Verification Code",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Please enter 4 digit code you received on your email",
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 180),
              child: numberInput(controller: inputOTP),
            ),
            ElevatedButton(
              onPressed: () {
                verifyOTP(inputOTP.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  String email;
  RegisterPage({super.key, required this.email});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController pswController = TextEditingController();
  TextEditingController confirmpswController = TextEditingController();

  void Register(email, psw, confirmpsw) async {
    if (psw.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
          getErrorSnackbar("Password must be at least 4 characters long"));
      return;
    } else if (psw != confirmpsw) {
      ScaffoldMessenger.of(context)
          .showSnackBar(getErrorSnackbar("Passwords do not match"));
      return;
    }
    final Uri _uri = Uri.parse("http://${Config.getServerPath()}/register");
    http.Response response =
        await http.post(_uri, body: {"email": email, "psw": psw});
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(getErrorSnackbar(response.body));
      return;
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false, // Remove all routes
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 8),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          "images/SecuredPassword.jpg",
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 16), // Add spacing
                      Text(
                        "Create password for",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.email,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Enter password: ",
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                      pswInput(
                        controller: pswController,
                        label: "Password",
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Re-enter password: ",
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                      pswInput(
                        controller: confirmpswController,
                        label: "Confirm password",
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.green),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Cancel',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Register(widget.email, pswController.text,
                                  confirmpswController.text);
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.green,
                              side: const BorderSide(color: Colors.green),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
