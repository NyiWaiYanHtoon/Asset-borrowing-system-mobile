// ignore_for_file: empty_constructor_bodies, prefer_const_constructors
import 'package:asset_borrowing_system_mobile/common_pages/config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class searchSection extends StatefulWidget {
  final Function(String?, String?, DateTime?, DateTime?) runFilter;
  final bool includeDateone;
  final bool includeDatetwo;

  String dateLabelone;
  String dateLabeltwo;
  searchSection(
      {super.key,
      required this.runFilter,
      required this.includeDateone,
      required this.includeDatetwo,
      this.dateLabelone = "Pick Date",
      this.dateLabeltwo = "Pick Date",});

  @override
  State<searchSection> createState() => _searchSectionState();
}

class _searchSectionState extends State<searchSection> {
  String? ddValue;
  DateTime? searchDateone;
  DateTime? searchDatetwo;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ddValue = "name";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onSubmitted: (searchValue) {
            widget.runFilter(searchValue, ddValue, searchDateone, searchDatetwo);
          },
          decoration: InputDecoration(
              labelText: "Search",
              prefixIcon: Icon(Icons.search),
              suffixIcon: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: ddValue,
                  icon: const Icon(Icons.arrow_drop_down_sharp,
                      color: Colors.black),
                  dropdownColor: Colors.white,
                  items: <String>['name', 'status', 'type'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      ddValue = value;
                    });
                  },
                  iconSize: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                ),
              )),
        ),
        const SizedBox(height: 16),
        if (widget.includeDateone)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: searchDateone,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      searchDateone = selectedDate;
                    });
                  }
                },
                icon: Icon(
                  Icons.calendar_today,
                  color: Colors.green[800],
                ),
                label: Text(
                  "Pick Date",
                  style: TextStyle(color: Colors.green[800]),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  searchDateone=null;
                },
                icon: Icon(
                  Icons.remove_circle,
                  color: Colors.redAccent,
                ),
                label: Text(
                  "Remove Date",
                  style: TextStyle(color: Colors.redAccent),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.dateLabelone,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      searchDateone == null
                          ? ""
                          : DateFormat('MMM d, yyyy').format(searchDateone!),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 10,),
          if (widget.includeDatetwo)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: searchDatetwo,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      searchDatetwo = selectedDate;
                    });
                  }
                },
                icon: Icon(
                  Icons.calendar_today,
                  color: Colors.green[800],
                ),
                label: Text(
                  "Pick Date",
                  style: TextStyle(color: Colors.green[800]),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  searchDatetwo=null;
                },
                icon: Icon(
                  Icons.remove_circle,
                  color: Colors.redAccent,
                ),
                label: Text(
                  "Remove Date",
                  style: TextStyle(color: Colors.redAccent),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.dateLabeltwo,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      searchDatetwo == null
                          ? ""
                          : DateFormat('MMM d, yyyy').format(searchDatetwo!),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
      ],
    );
  }
}

class Navbar extends StatelessWidget {
  String role;
  final int currentIndex;
  final Function(int) onTab;

  Navbar(
      {super.key,
      required this.currentIndex,
      required this.onTab,
      required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      // staff, student, Lecturer navbar para: Currentindex
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        items: [
          if (role != "Student")
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Assets',
          ),
          if (role == "Staff")
            const BottomNavigationBarItem(
              icon: Icon(Icons.swap_vert),
              label: 'Manage',
            ),
          if (role != "Staff")
            const BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Requests',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: const Color(0xFF003366),
        unselectedItemColor: Colors.black,
        currentIndex: currentIndex,
        onTap: onTab, // this will pass Tab(new tabbed index)
      ),
    );
  }
}

class ProfilePicture extends StatelessWidget {
  final String img_string; // Renamed to follow Dart's camel case convention
  final VoidCallback onTap;
  final double size;

  const ProfilePicture({
    Key? key,
    required this.img_string,
    required this.onTap,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Align(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: size,
            backgroundImage: img_string.isNotEmpty
                ? (img_string.startsWith('http')
                    ? NetworkImage(img_string) // For online image URL
                    : AssetImage(img_string)
                        as ImageProvider) // For local asset image
                : null,
            backgroundColor: Colors.grey[300],
            child: img_string.isEmpty
                ? const Icon(Icons.person, size: 30, color: Colors.grey)
                : null,
          ),
        ),
      ),
    );
  }
}

SnackBar getErrorSnackbar(message) {
  return SnackBar(
    content: Row(
      children: [
        const Icon(Icons.error, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: Colors.red,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(10),
    elevation: 6,
    duration: const Duration(seconds: 4),
    action: SnackBarAction(
      label: 'Retry',
      textColor: Colors.white,
      onPressed: () {},
    ),
  );
}

SnackBar getSuccessSnackBar(message) {
  return SnackBar(
    content: Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 2),
  );
}

class NoResultsWidget extends StatelessWidget {
  final String title;

  const NoResultsWidget({
    Key? key,
    this.title = "No Results Found",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>> retrieveData() async {
  try {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('jwt_token');
  final Uri uri = Uri.parse("http://${Config.getServerPath()}/getUser");
    http.Response response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    return {"Error Code": response.statusCode};
  } catch (e) {
    return {"Error catched": e};
  }
}
