// ignore_for_file: prefer_if_null_operators, prefer_const_constructors
import 'package:asset_borrowing_system_mobile/common_pages/config.dart';
import 'package:asset_borrowing_system_mobile/components/cards.dart';
import 'package:asset_borrowing_system_mobile/components/global.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class Studentrequest extends StatefulWidget {
  Studentrequest({super.key});

  @override
  State<Studentrequest> createState() => _StudentrequestState();
}

class _StudentrequestState extends State<Studentrequest> {
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    if (token == null) {
      setState(() {
        isLoading = true;
      });
      return;
    }
    final Uri uri =
        Uri.parse('http://${Config.getServerPath()}/getRequest/student');
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
          List<dynamic> fetchedRequests = jsonDecode(response.body);
          setState(() {
            requests = fetchedRequests;
            filteredRequests = requests;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error occurred while fetching requests: $e");
    }
  }

  void CancelRequest(int id) async {
    final Uri _uri = Uri.parse('http://${Config.getServerPath()}/cancel');
    http.Response response =
        await http.post(_uri, body: {"transaction_id": id.toString()});
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        getSuccessSnackBar(response.body),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        getErrorSnackbar(response.body),
      );
    }
    setState(() {
      getRequests();
    });
  }

  void runFilter(String? searchValue, String? ddValue, DateTime? searchDate) {
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
      if (searchDate != null) {
        setState(() {
          filteredRequests = filteredRequests.where((request) {
            DateTime dataDate = DateTime.parse(request["booked_date"]).toLocal();
            dataDate = DateTime(dataDate.year, dataDate.month, dataDate.day);
            searchDate =
                DateTime(searchDate!.year, searchDate!.month, searchDate!.day);
            return searchDate == dataDate;
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
              runFilter(searchValue, ddValue, searchDateone);
            },
            includeDateone: true,
            dateLabelone: "Booked Date",
            includeDatetwo: false,
          ),
          isLoading
              ? Expanded(child: Center(child: CircularProgressIndicator()))
              : requests.isEmpty
                  ? Expanded(child: Center(child: NoResultsWidget()))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: filteredRequests.length,
                        itemBuilder: (content, index) => TransactionCard(
                          asset_name: filteredRequests[index]['asset_name'],
                          type_string: filteredRequests[index]['asset_type'],
                          img_string: filteredRequests[index]['image'] == null
                              ? "images/no-image.webp"
                              : filteredRequests[index]['image'],
                          date_label_1: "Booked on",
                          date_1: DateFormat('yyyy-MM-dd').format(
                              DateTime.parse(
                                  filteredRequests[index]['booked_date']).toLocal()),
                          status: filteredRequests[index]["status"],
                          cancel_button: true,
                          cancelOnPressed: () {
                            CancelRequest(filteredRequests[index]['id']);
                          },
                          size: 160,
                        ),
                      ),
                    )
        ],
      ),
    );
  }
}
