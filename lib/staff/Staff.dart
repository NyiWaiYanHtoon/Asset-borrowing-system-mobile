import 'package:asset_borrowing_system_mobile/common_pages/Dashboard.dart';
import 'package:asset_borrowing_system_mobile/components/global.dart';
import 'package:asset_borrowing_system_mobile/common_pages/profile.dart';
import 'package:asset_borrowing_system_mobile/staff/Staffhistory.dart';
import 'package:asset_borrowing_system_mobile/staff/Staffmanage.dart';
import 'package:asset_borrowing_system_mobile/staff/Stafflist.dart';
import 'package:asset_borrowing_system_mobile/staff/assetAddEdit.dart';
import 'package:flutter/material.dart';

class Staff extends StatefulWidget {
  int currentTab;
  Staff({super.key, this.currentTab=0});

  @override
  _StaffState createState() => _StaffState();
}

class _StaffState extends State<Staff> {
  TextEditingController searchController = TextEditingController();

  List<Widget> get _screen => [
    const Dashboard(),
    Stafflist(),
    Staffmanage(),
    Staffthistory(),
    ProfilePage(role: "Staff",),
  ];

  @override
  void initState() {
    super.initState();
    retrieveUserData();
  }
  Map<String, dynamic> user = {
    "userId": "107",
    "username": "Ross",
    "email": "ross@gmail.com",
  };
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
        title: Text(
                [
                  'Dashboard',
                  'Asset List',
                  'Manage',
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
        role: "Staff",
        currentIndex: widget.currentTab,
        onTab: (int index) {
          //when function is called back inside object, parameter index is passed
          setState(() {
            widget.currentTab = index;
            retrieveUserData();
          });
        },
      ),
      floatingActionButton: widget.currentTab == 1
          ? //if only it is asset List page
          FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddEditItem(isEdit: false,)),
                );
              },
              backgroundColor: const Color(0xFF003366),
              shape: const CircleBorder(),
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}
