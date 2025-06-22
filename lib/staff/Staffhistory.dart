// ignore_for_file: prefer_if_null_operators
import 'package:asset_borrowing_system_mobile/common_pages/config.dart';
import 'package:asset_borrowing_system_mobile/components/cards.dart';
import 'package:asset_borrowing_system_mobile/components/global.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'dart:convert';

class Staffthistory extends StatefulWidget {
  Staffthistory(
      {super.key});

  @override
  State<Staffthistory> createState() => _StaffthistoryState();
}

class _StaffthistoryState extends State<Staffthistory> {
  bool isLoading = true;
  List<dynamic> history = [];
  List<dynamic> filteredHistory = [];
  @override
  void initState() {
    super.initState();
    isLoading = true;
    getHistory();
  }

  void getHistory() async {
    final Uri uri = Uri.parse('http://${Config.getServerPath()}/history/staff');
    try {
      http.Response response = await http.get(uri);
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
          List<dynamic> fetchedHistory = jsonDecode(response.body);
          setState(() {
            history = fetchedHistory;
            filteredHistory = history;
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

  void runFilter(String? searchValue, String? ddValue){
    Map<String, String> ddMap = {
      "name": "asset_name",
      "type": "asset_type",
      "status": "status"
    };
    if (searchValue != null && ddValue != null) {
      setState(() {
        filteredHistory = history
            .where((eachHistory) => eachHistory[ddMap[ddValue]]
                .toLowerCase()
                .contains(searchValue.toLowerCase()))
            .toList();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          searchSection(
            runFilter: (searchValue, ddValue, dateValueone, dateValuetwo){
              runFilter(searchValue, ddValue);
            }, 
            includeDateone: false, 
            includeDatetwo: false
          ),
          isLoading
          ? Expanded(child: Center(child: CircularProgressIndicator(),))
          : filteredHistory.isEmpty
            ? Expanded(child: Center(child: NoResultsWidget(),))
            : Expanded(
              child: ListView.builder(
                itemCount: filteredHistory.length,
                itemBuilder: (content, index)=> TransactionCard(
                  asset_name: filteredHistory[index]['asset_name'],
                  type_string: filteredHistory[index]['asset_type'],
                  img_string: filteredHistory[index]['image'] == null
                      ? "images/no-image.webp"
                      : filteredHistory[index]['image'],
                  person_name: filteredHistory[index]['borrower_name'],
                  person_pic_string: filteredHistory[index]['profile_pic'] == null
                      ? "images/profile.jpg"
                      : filteredHistory[index]['profile_pic'],
                  status: filteredHistory[index]["status"],
                  size: 145,
                )
              ),
            )
        ],
      ),
    );
  }
}
