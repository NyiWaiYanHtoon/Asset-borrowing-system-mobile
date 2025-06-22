// ignore_for_file: prefer_if_null_operators
import 'package:asset_borrowing_system_mobile/common_pages/config.dart';
import 'package:asset_borrowing_system_mobile/components/cards.dart';
import 'package:asset_borrowing_system_mobile/components/global.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as http;

class Lecturerrequest extends StatefulWidget {
  Lecturerrequest({super.key});

  @override
  State<Lecturerrequest> createState() => _LecturerrequestState();
}

class _LecturerrequestState extends State<Lecturerrequest> {
  List<dynamic> requests = [];
  List<dynamic> filteredRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    getRequests();
  }

  void getRequests() async {
    final Uri uri =
        Uri.parse('http://${Config.getServerPath()}/getRequest/lecturer');
    try {
      http.Response response = await http.get(uri);
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
          List<dynamic> fetchedRequests = jsonDecode(response.body);
          setState(() {
            requests = fetchedRequests;
            filteredRequests = requests;
          });
          print(filteredRequests);
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error occurred while fetching requests: $e");
    }
  }

  void Approve(transaction_id, asset_id, action) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    final Uri uri;
    if (action == "approve") {
      uri = Uri.parse("http://${Config.getServerPath()}/approve");
    } else {
      uri = Uri.parse("http://${Config.getServerPath()}/reject");
    }
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
  void runFilter(String? searchValue, String? ddValue, DateTime? searchDateone, DateTime? searchDatetwo) {
    Map<String, String> ddMap = {
      //map with data base column
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
      if (searchDateone != null) {
        setState(() {
          filteredRequests = filteredRequests.where((request) {
            DateTime dataDate = DateTime.parse(request["booked_date"]).toLocal();
            dataDate = DateTime(dataDate.year, dataDate.month, dataDate.day);
            searchDateone =
                DateTime(searchDateone!.year, searchDateone!.month, searchDateone!.day);
            return searchDateone == dataDate;
          }).toList();
        });
      }
      if (searchDatetwo != null) {
        setState(() {
          filteredRequests = filteredRequests.where((request) {
            DateTime dataDate = DateTime.parse(request['expected_return_date']).toLocal();
            dataDate = DateTime(dataDate.year, dataDate.month, dataDate.day);
            searchDatetwo =
                DateTime(searchDatetwo!.year, searchDatetwo!.month, searchDatetwo!.day);
            return searchDatetwo == dataDate;
          }).toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          searchSection(
            runFilter: (searchValue, ddValue, searchDateone, searchDatetwo) {
              runFilter(searchValue, ddValue, searchDateone, searchDatetwo);
            },
            includeDateone: true,
            dateLabelone: "Requested Date",
            includeDatetwo: true,
            dateLabeltwo: "Return Date",
          ),
          isLoading
              ? Expanded(child: Center(child: CircularProgressIndicator()))
              : filteredRequests.isEmpty
                  ? Expanded(child: Center(child: NoResultsWidget()))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: filteredRequests.length,
                        itemBuilder: (content, index) => TransactionCard(
                          asset_name: filteredRequests[index]["asset_name"],
                          type_string: filteredRequests[index]['asset_type'],
                          img_string: filteredRequests[index]['image'] == null
                              ? "images/no-image.webp"
                              : filteredRequests[index]['image'],
                          person_name: filteredRequests[index]["borrower_name"],
                          person_pic_string:
                              filteredRequests[index]["borrower_pic"] == null
                                  ? "images/profile.jpg"
                                  : filteredRequests[index]["borrower_pic"],
                          date_label_1: "Requested Date",
                          date_1: DateFormat('yyyy-MM-dd').format(
                              DateTime.parse(
                                      filteredRequests[index]['booked_date'])
                                  .toLocal()),
                          approve_button: true,
                          approveOnPressed: () {
                            Approve(filteredRequests[index]["id"],
                                filteredRequests[index]["asset_id"], "approve");
                          },
                          reject_button: true,
                          rejectOnPressed: () {
                            Approve(
                                filteredRequests[index]["id"],
                                filteredRequests[index]["asset_id"],
                                "disapprove");
                          },
                          size: 200,
                          date_label_2: "Expected return date",
                          date_2: DateFormat('yyyy-MM-dd').format(
                              DateTime.parse(filteredRequests[index]
                                      ['expected_return_date'])
                                  .toLocal()),
                          status: filteredRequests[index]['status'],
                        ),
                      ),
                    )
        ],
      ),
    );
  }
}
