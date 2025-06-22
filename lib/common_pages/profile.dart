// ignore_for_file: prefer_if_null_operators, curly_braces_in_flow_control_structures
import 'package:asset_borrowing_system_mobile/student/Student.dart';
import 'package:asset_borrowing_system_mobile/common_pages/login.dart';
import 'package:asset_borrowing_system_mobile/components/cards.dart';
import 'package:asset_borrowing_system_mobile/common_pages/edit_profile.dart';
import 'package:asset_borrowing_system_mobile/components/global.dart';
import 'package:asset_borrowing_system_mobile/lecturer/Lecturer.dart';
import 'package:asset_borrowing_system_mobile/staff/Staff.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  String role;
  ProfilePage({super.key, required this.role});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> user = {
    "userId": "107",
    "username": "Ross",
    "email": "ross@gmail.com",
  };

  @override
  void initState() {
    super.initState();
    retrieveUserData();
  }

  Future<void> retrieveUserData() async {
    final retrievedUser = await retrieveData();
    setState(() {
      user = retrievedUser;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        profileCard(
          profileUrl: user["profile_pic"] == null
              ? "images/profile.jpg"
              : user["profile_pic"],
          name: user['username'],
          email: user['email'],
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileEditPage()),
            );
          },
        ),
        const SizedBox(height: 20),
        Container(
          margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: const Text("Quick access",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),),
        ),
        if (widget.role != "Student")
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          widget.role == "Lecturer" ? Lecturer() : Staff()));
            },
          ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.list),
          title: const Text('Asset List'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Widget destination = Student();
            if (widget.role == "Lecturer") {
              destination = Lecturer(
                currentTab: 1,
              );
            }
            if (widget.role == "Staff")
              destination = Staff(
                currentTab: 1,
              );
            if (widget.role == "Student") destination = Student();
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => destination));
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('FAQ'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Log out'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove('jwt_token');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
        const Divider(),
      ],
    );
  }
}
