// ignore_for_file: prefer_if_null_operators
import 'package:asset_borrowing_system_mobile/common_pages/config.dart';
import 'package:asset_borrowing_system_mobile/components/cards.dart';
import 'package:asset_borrowing_system_mobile/components/global.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Staffmanage extends StatefulWidget {
  Staffmanage({super.key});

  @override
  State<Staffmanage> createState() => _StaffmanageState();
}

class _StaffmanageState extends State<Staffmanage> {
  List<dynamic> requests = [];
  List<dynamic> approvedRequests = [];
  List<dynamic> holdingRequests = [];
  List<dynamic> filteredRequests = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    isLoading = true;
    getRequests();
  }

  void getRequests() async {
    final Uri _uri = Uri.parse('http://${Config.getServerPath()}/manage/staff');
    http.Response response = await http.get(_uri);
    if (response.statusCode >= 500) {
      //if server error
      setState(() {
        isLoading = true;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      if (response.statusCode == 200) {
        setState(() {
          List<dynamic> fetchedRequests = jsonDecode(response.body);
          requests = fetchedRequests;
          filteredRequests = fetchedRequests;
          approvedRequests = requests
              .where((eachReq) => eachReq["status"] == "approved")
              .toList();
          holdingRequests = requests
              .where((eachReq) => eachReq["status"] == "holding")
              .toList();
        });
      }
    }
  }

  void takeoutItem(int transaction_id, int asset_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    final Uri uri;
    uri = Uri.parse("http://${Config.getServerPath()}/takeout");
    Map<String, dynamic> bodyData = {
      'asset_id': asset_id,
      'transaction_id': transaction_id,
    };
    try {
      http.Response response = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(bodyData));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(getSuccessSnackBar(response.body));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(getErrorSnackbar(response.body));
      }
    } catch (e) {
      print(e);
    }
    getRequests();
  }

  void returnItem(int transaction_id, int asset_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    final Uri uri;
    uri = Uri.parse("http://${Config.getServerPath()}/return");
    Map<String, dynamic> bodyData = {
      'asset_id': asset_id,
      'transaction_id': transaction_id,
    };
    try {
      http.Response response = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(bodyData));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(getSuccessSnackBar(response.body));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(getErrorSnackbar(response.body));
      }
    } catch (e) {
      print(e);
    }
    getRequests();
  }

  void runFilter(String? searchValue, String? ddValue, DateTime? searchDate) {
    Map<String, String> ddMap = {
      "name": "asset_name",
      "type": "asset_type",
      "status": "status"
    };
    if (searchValue != null && ddValue != null) {
      setState(() {
        filteredRequests = requests
            .where((request) => request[ddMap[ddValue]]
                .toLowerCase()
                .contains(searchValue.toLowerCase()))
            .toList();
      });
      if (searchDate != null) {
        filteredRequests = filteredRequests.where((request) {
          DateTime dataDate = DateTime.parse(request["validated_date"]).toLocal();
          dataDate = DateTime(dataDate.year, dataDate.month, dataDate.day);
          searchDate =
              DateTime(searchDate!.year, searchDate!.month, searchDate!.day);
          return searchDate == dataDate;
        }).toList();
      }
      setState(() {
        approvedRequests = filteredRequests
            .where((request) => request["status"] == "approved")
            .toList();
        holdingRequests = filteredRequests
            .where((request) => request["status"] == "holding")
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
                runFilter:
                    (searchValue, ddValue, searchDateone, searchDatetwo) {
                  runFilter(searchValue, ddValue, searchDateone);
                },
                includeDateone: true,
                dateLabelone: "Validated date",
                includeDatetwo: false),
            const TabBar(
              indicatorColor: Color(0xFF2457C5),
              labelColor: Color(0xFF2457C5),
              unselectedLabelColor: Colors.black,
              tabs: [
                Tab(text: "Take Out"),
                Tab(text: "Return"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  isLoading
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : approvedRequests.isEmpty
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: Center(
                                child: NoResultsWidget(),
                              ),
                            )
                          : ListView.builder(
                              itemCount: approvedRequests.length,
                              itemBuilder: (context, index) => TransactionCard(
                                asset_name: approvedRequests[index]
                                    ['asset_name'],
                                type_string: approvedRequests[index]
                                    ['asset_type'],
                                img_string:
                                    approvedRequests[index]['image_url'] == null
                                        ? "images/no-image.webp"
                                        : approvedRequests[index]['image_url'],
                                person_name: approvedRequests[index]
                                    ['borrower_name'],
                                person_pic_string: approvedRequests[index]
                                            ['profile_pic'] ==
                                        null
                                    ? "images/profile.jpg"
                                    : approvedRequests[index]['profile_pic'],
                                date_label_1: "Approved on",
                                date_1: DateFormat('yyyy-MM-dd').format(
                                    DateTime.parse(approvedRequests[index]
                                        ["validated_date"]).toLocal()),
                                status: holdingRequests[index]['status'],
                                return_button: true,
                                returnOnPressed: () {
                                  returnItem(approvedRequests[index]['id'],
                                      approvedRequests[index]['asset_id']);
                                },
                                size: 160,
                              ),
                            ),
                  isLoading
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : holdingRequests.isEmpty
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: Center(
                                child: NoResultsWidget(),
                              ),
                            )
                          : ListView.builder(
                              itemCount: holdingRequests.length,
                              itemBuilder: (context, index) => TransactionCard(
                                asset_name: holdingRequests[index]
                                    ['asset_name'],
                                type_string: holdingRequests[index]
                                    ['asset_type'],
                                img_string:
                                    holdingRequests[index]['image_url'] == null
                                        ? "images/no-image.webp"
                                        : holdingRequests[index]['image_url'],
                                person_name: holdingRequests[index]
                                    ['borrower_name'],
                                person_pic_string: holdingRequests[index]
                                            ['profile_pic'] ==
                                        null
                                    ? "images/profile.jpg"
                                    : holdingRequests[index]['profile_pic'],
                                date_label_1: "Approved on",
                                date_1: DateFormat('yyyy-MM-dd').format(
                                    DateTime.parse(holdingRequests[index]
                                        ["validated_date"]).toLocal()),
                                status: holdingRequests[index]['status'],
                                return_button: true,
                                returnOnPressed: () {
                                  returnItem(holdingRequests[index]['id'],
                                      holdingRequests[index]['asset_id']);
                                },
                                size: 160,
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
