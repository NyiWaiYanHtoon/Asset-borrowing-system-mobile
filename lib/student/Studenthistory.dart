// ignore_for_file: prefer_if_null_operators, prefer_const_constructors
import 'package:asset_borrowing_system_mobile/common_pages/config.dart';
import 'package:asset_borrowing_system_mobile/components/cards.dart';
import 'package:asset_borrowing_system_mobile/components/global.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as http;
import 'dart:convert';

class Studenthistory extends StatefulWidget {
  Studenthistory({super.key});

  @override
  State<Studenthistory> createState() => _StudenthistoryState();
}

class _StudenthistoryState extends State<Studenthistory> {
  List<dynamic> allHistory = [];
  List<dynamic> holdingHistory = [];
  List<dynamic> returnedHistory = [];
  List<dynamic> filteredHistory = [];
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
        Uri.parse('http://${Config.getServerPath()}/history/student');
    try {
      http.Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode >= 500) {
        //if server error
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
            holdingHistory = filteredHistory
                .where((eachHistory) => eachHistory["status"] == "holding")
                .toList();
            returnedHistory = filteredHistory
                .where((eachHistory) => eachHistory["status"] == "returned")
                .toList();
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = true;
      });
      print("Error occurred while fetching allHistory: $e");
    }
  }

  void runFilter(String? searchValue, String? ddValue, DateTime? searchDateone,
      DateTime? searchDatetwo) {
    //map with data base column
    Map<String, String> ddMap = {
      "name": "asset_name",
      "type": "asset_type",
      "status": "status"
    };
    if (searchValue != null && ddValue != null) {
      setState(() {
        filteredHistory = allHistory
            .where((history) => history[ddMap[ddValue]]
                .toLowerCase()
                .contains(searchValue.toLowerCase()))
            .toList();
      });
      if (searchDateone != null) {
        filteredHistory = filteredHistory.where((history) {
          DateTime dataDate = DateTime.parse(history["borrow_date"]).toLocal();
          dataDate = DateTime(dataDate.year, dataDate.month, dataDate.day);
          searchDateone = DateTime(
              searchDateone!.year, searchDateone!.month, searchDateone!.day);
          return searchDateone == dataDate;
        }).toList();
      }
      if (searchDatetwo != null) {
        filteredHistory = filteredHistory.where((history) {
          DateTime dataDate = DateTime.parse(history["returned_date"]).toLocal();
          dataDate = DateTime(dataDate.year, dataDate.month, dataDate.day);
          searchDatetwo = DateTime(
              searchDatetwo!.year, searchDatetwo!.month, searchDatetwo!.day);
          return searchDatetwo == dataDate;
        }).toList();
      }
      setState(() {
        holdingHistory = filteredHistory
            .where((eachHistory) => eachHistory["status"] == "holding")
            .toList();
        returnedHistory = filteredHistory
            .where((eachHistory) => eachHistory["status"] == "returned")
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            searchSection(
              runFilter: (searchValue, ddValue, searchDateone, searchDatetwo) {
                runFilter(searchValue, ddValue, searchDateone, searchDatetwo);
              },
              includeDateone: true,
              dateLabelone: "Borrow Date",
              includeDatetwo: true,
              dateLabeltwo: "Return Date",
            ),
            const TabBar(
              indicatorColor: Color(0xFF2457C5),
              labelColor: Color(0xFF2457C5),
              unselectedLabelColor: Colors.black,
              tabs: [
                Tab(text: "Holding items"),
                Tab(text: "Returned items"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // holding items
                  isLoading
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.6, // Ensures full height
                          child: Center(child: CircularProgressIndicator()))
                      : holdingHistory.isEmpty
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Center(child: NoResultsWidget()))
                          : ListView.builder(
                              itemCount: holdingHistory.length,
                              itemBuilder: (content, index) => TransactionCard(
                                asset_name: holdingHistory[index]['asset_name'],
                                type_string: holdingHistory[index]
                                    ['asset_type'],
                                img_string:
                                    holdingHistory[index]['image'] == null
                                        ? "images/no-image.webp"
                                        : holdingHistory[index]['image'],
                                date_label_1: "Borrow date",
                                date_1: DateFormat('yyyy-MM-dd').format(
                                    DateTime.parse(
                                        holdingHistory[index]['borrow_date']).toLocal()),
                                date_label_2: "Return date",
                                date_2: DateFormat('yyyy-MM-dd').format(
                                    DateTime.parse(holdingHistory[index]
                                        ['expected_return_date']).toLocal()),
                                status: holdingHistory[index]["status"],
                                size: 175,
                              ),
                            ),

                  //returned items
                  isLoading
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.6, // Ensures full height
                          child: Center(child: CircularProgressIndicator()))
                      : returnedHistory.isEmpty
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  0.6, // Ensures full height
                              child: Center(child: NoResultsWidget()))
                          : ListView.builder(
                              itemCount: returnedHistory.length,
                              itemBuilder: (content, index) => TransactionCard(
                                asset_name: returnedHistory[index]
                                    ['asset_name'],
                                type_string: returnedHistory[index]
                                    ['asset_type'],
                                img_string:
                                    returnedHistory[index]['image'] == null
                                        ? "images/no-image.webp"
                                        : returnedHistory[index]['image'],
                                date_label_1: "Borrow date",
                                date_1: DateFormat('yyyy-MM-dd').format(
                                    DateTime.parse(
                                        returnedHistory[index]['borrow_date']).toLocal()),
                                date_label_2: "Return date",
                                date_2: DateFormat('yyyy-MM-dd').format(
                                    DateTime.parse(returnedHistory[index]
                                        ['expected_return_date']).toLocal()),
                                status: returnedHistory[index]["status"],
                                size: 175,
                              ),
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
