// ignore_for_file: prefer_if_null_operators
import 'package:asset_borrowing_system_mobile/common_pages/config.dart';
import 'package:asset_borrowing_system_mobile/components/cards.dart';
import 'package:asset_borrowing_system_mobile/components/global.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as http;
import 'dart:convert';

class Lecturerhistory extends StatefulWidget {
  Lecturerhistory({
    super.key,
  });

  @override
  State<Lecturerhistory> createState() => _LecturerhistoryState();
}

class _LecturerhistoryState extends State<Lecturerhistory> {
  List<dynamic> allHistory = [];
  List<dynamic> filteredHistory = [];
  List<dynamic> approvedHistory = [];
  List<dynamic> disapprovedHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    getHistory();
  }

  void getHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    final Uri uri =
        Uri.parse('http://${Config.getServerPath()}/history/lecturer');
    try {
      http.Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode >= 500) {
        // if server error
        setState(() {
          isLoading = true;
        });
      } else {
        //if 200 or 400
        setState(() {
          isLoading = false;
        });
        if (response.statusCode == 200) {
          List<dynamic> fetchedHistory = jsonDecode(response.body);
          setState(() {
            allHistory = fetchedHistory;
            filteredHistory = allHistory;
            approvedHistory = filteredHistory
                .where((eachHistory) => eachHistory["status"] != "disapproved")
                .toList();
            disapprovedHistory = filteredHistory
                .where((eachHistory) => eachHistory["status"] == "disapproved")
                .toList();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = true;
      });
      print("Error occurred while fetching requests: $e");
    }
  }

  void runFilter(String? searchValue, String? ddValue, DateTime? searchDate) {
    Map<String, String> ddMap = {
      //map with data base column
      "name": "asset_name",
      "type": "asset_type",
      "status": "status"
    };
    if (searchValue != null && ddValue != null) {
      filteredHistory = allHistory
          .where((request) => request[ddMap[ddValue]]
              .toLowerCase()
              .contains(searchValue.toLowerCase()))
          .toList();

      if (searchDate != null) {
        filteredHistory = filteredHistory.where((request) {
          DateTime dataDate =
              DateTime.parse(request["validated_date"]).toLocal();
          dataDate = DateTime(dataDate.year, dataDate.month, dataDate.day);
          searchDate =
              DateTime(searchDate!.year, searchDate!.month, searchDate!.day);
          return searchDate == dataDate;
        }).toList();
      }
      setState(() {
        approvedHistory = filteredHistory
                .where((eachHistory) => eachHistory["status"] != "disapproved")
                .toList();
            disapprovedHistory = filteredHistory
                .where((eachHistory) => eachHistory["status"] == "disapproved")
                .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            searchSection(
              runFilter: (searchValue, ddValue, searchDateone, searchDatetwo) {
                runFilter(searchValue, ddValue, searchDateone);
              },
              includeDateone: true,
              dateLabelone: "Validated Date",
              includeDatetwo: false,
            ),
            const TabBar(
              indicatorColor: Color(0xFF2457C5),
              labelColor: Color(0xFF2457C5),
              unselectedLabelColor: Colors.black,
              tabs: [
                Tab(text: "All"),
                Tab(text: "Approved"),
                Tab(text: "Rejected"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    buildHistory("Validated on", filteredHistory, isLoading),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    buildHistory("Approved on", approvedHistory, isLoading),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    buildHistory("Rejected on", disapprovedHistory, isLoading),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildHistory(String date_label, histories, isLoading) {
  return Column(children: [
    isLoading
        ? Expanded(child: Center(child: CircularProgressIndicator()))
        : histories.isEmpty
            ? Expanded(child: Center(child: NoResultsWidget()))
            : Expanded(
                child: ListView.builder(
                  itemCount: histories.length,
                  itemBuilder: (content, index) => TransactionCard(
                      asset_name: histories[index]["asset_name"],
                      type_string: histories[index]["asset_type"],
                      img_string: histories[index]["image_url"] == null
                          ? "images/no-image.webp"
                          : histories[index]["image_url"],
                      date_label_1: date_label,
                      date_1: DateFormat('yyyy-MM-dd').format(
                          DateTime.parse(histories[index]['validated_date'])
                              .toLocal()),
                      person_name: histories[index]["borrower_name"],
                      person_pic_string:
                          histories[index]["borrower_profile"] == null
                              ? "images/profile.jpg"
                              : histories[index]["borrower_profile"],
                      status: histories[index]["status"],
                      size: 165),
                ),
              )
  ]);
}
