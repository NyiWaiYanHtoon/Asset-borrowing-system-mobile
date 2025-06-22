import 'package:asset_borrowing_system_mobile/common_pages/profile.dart';
import 'package:asset_borrowing_system_mobile/components/global.dart';
import 'package:asset_borrowing_system_mobile/student/Studenthistory.dart';
import 'package:asset_borrowing_system_mobile/student/Studentlist.dart';
import 'package:asset_borrowing_system_mobile/student/Studentrequest.dart';
import 'package:flutter/material.dart';

class Student extends StatefulWidget {
  int currentTab;
  Student({super.key, this.currentTab=0});

  @override
  _StudentState createState() => _StudentState();
}

class _StudentState extends State<Student> {
  TextEditingController searchController = TextEditingController();

  List<Widget> get _screen => [
    Studentlist(),
    Studentrequest(),
    Studenthistory(),
    ProfilePage(role: "Student",),
  ];
  void initState() {
    super.initState();
    retrieveUserData();
  }
  Map<String, dynamic> user = {};
  Future<void> retrieveUserData() async {
    final retrievedUser = await retrieveData();
    setState(() {
      user = retrievedUser;
    });
  }
  @override
  Widget build(BuildContext context){
    retrieveUserData();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        title: Text(
                [
                  'Asset List',
                  'Requests',
                  'History',
                  'Profile'
                ][widget.currentTab],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                ),
              ),
        actions: [
            ProfilePicture(
                img_string: user["profile_pic"]==null? "images/profile.jpg": user["profile_pic"],
                size: 18,
                onTap: () {}),
        ],
      ),
      body: _screen[widget.currentTab],
      bottomNavigationBar: Navbar(
        role: "Student",
        currentIndex: widget.currentTab,
        onTab: (int index) {
          setState(() {
            widget.currentTab = index;
          });
        },
      ),
    );
  }
}
