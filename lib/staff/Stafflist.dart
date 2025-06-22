// ignore_for_file: prefer_const_constructors

import 'package:asset_borrowing_system_mobile/common_pages/config.dart';
import 'package:asset_borrowing_system_mobile/components/cards.dart';
import 'package:asset_borrowing_system_mobile/components/global.dart';
import 'package:asset_borrowing_system_mobile/staff/assetAddEdit.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'dart:convert';

class Stafflist extends StatefulWidget {
  Stafflist({super.key});
  @override
  State<Stafflist> createState() => _StafflistState();
}

class _StafflistState extends State<Stafflist> {
  List<dynamic> assets = [];
  List<dynamic> filteredAssets = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    isLoading = true;
    getAsset();
  }

  void getAsset() async {
    final Uri _uri = Uri.parse('http://${Config.getServerPath()}/assets');
    http.Response response = await http.get(_uri);
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
        setState(() {
          assets = jsonDecode(response.body);
          filteredAssets = assets;
        });
      }
    }
  }

  void disableAsset(int? id) async {
    if (id != null) {
      final Uri _uri = Uri.parse('http://${Config.getServerPath()}/disable');
      http.Response response = await http.post(_uri, body: {"id": id.toString()});
      print(response.statusCode);
      if (response.statusCode == 200) {
        getAsset();
        print(response.body);
      }
    }
  }

  void runFilter(String? searchValue, String? ddValue) {
    if (searchValue != null && ddValue != null) {
      setState(() {
        filteredAssets = assets
            .where((asset) => asset[ddValue]
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
      child: Column(children: [
        searchSection(
          runFilter: (searchValue, ddValue, searchDateone, SearchDatetwo) {
            runFilter(searchValue, ddValue);
          },
          includeDateone: false,
          includeDatetwo: false,
        ),
        isLoading
            ? Expanded(
                child: Center(
                child: CircularProgressIndicator(),
              ))
            : filteredAssets.isEmpty
                ? Expanded(
                    child: Center(
                    child: NoResultsWidget(),
                  ))
                : Expanded(
                    child: ListView.builder(
                    itemCount: filteredAssets.length,
                    itemBuilder: (content, index) => AssetCard(
                      asset_name: filteredAssets[index]["name"],
                      type_string: filteredAssets[index]['type'],
                      status: filteredAssets[index]['status'],
                      img_string: filteredAssets[index]['image_url'] == null
                          ? "images/no-image.webp"
                          : filteredAssets[index]['image_url'],
                      edit_button: true,
                      editOnPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddEditItem(
                                    isEdit: true,
                                    asset: filteredAssets[index],
                                  )),
                        );
                      },
                      disable_button: true,
                      disableOnPressed: () {
                        disableAsset(filteredAssets[index]["id"]);
                      },
                    ),
                  ))
      ]),
    );
  }
}
