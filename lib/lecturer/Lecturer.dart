import 'package:asset_borrowing_system_mobile/common_pages/Dashboard.dart';
import 'package:asset_borrowing_system_mobile/common_pages/profile.dart';
import 'package:asset_borrowing_system_mobile/components/global.dart';
import 'package:asset_borrowing_system_mobile/lecturer/Lecturerhistory.dart';
import 'package:asset_borrowing_system_mobile/lecturer/Lecturerlist.dart';
import 'package:asset_borrowing_system_mobile/lecturer/Lecturerrequest.dart';
import 'package:flutter/material.dart';

class Lecturer extends StatefulWidget {
  int currentTab;
  Lecturer({super.key, this.currentTab = 0});

  @override
  _LecturerState createState() => _LecturerState();
}

class _LecturerState extends State<Lecturer> {
  TextEditingController searchController = TextEditingController();

  List<Widget> get _screen => [
        Dashboard(),
        Lecturerlist(),
        Lecturerrequest(),
        Lecturerhistory(),
        ProfilePage(
          role: "Lecturer",
        ),
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
  Widget build(BuildContext context) {
    retrieveUserData();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axis: Axis.horizontal,
                child: child,
              ),
            );
          },
          child: Text(
            [
              'Dashboard',
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
        ),
        actions: [
          ProfilePicture(
              img_string: user["profile_pic"] == null
                  ? "images/profile.jpg"
                  : user["profile_pic"],
              size: 18,
              onTap: () {}),
        ],
      ),
      body: _screen[widget.currentTab],
      bottomNavigationBar: Navbar(
        role: "Lecturer",
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
