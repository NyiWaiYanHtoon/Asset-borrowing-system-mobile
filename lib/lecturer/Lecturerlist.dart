// ignore_for_file: prefer_if_null_operators
import 'package:asset_borrowing_system_mobile/common_pages/config.dart';
import 'package:asset_borrowing_system_mobile/components/cards.dart';
import 'package:asset_borrowing_system_mobile/components/global.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'dart:convert';

class Lecturerlist extends StatefulWidget {
  Lecturerlist({super.key});

  @override
  State<Lecturerlist> createState() => _LecturerlistState();
}

class _LecturerlistState extends State<Lecturerlist> {
  List<dynamic> assets= [];
  List<dynamic> filteredAssets= [];
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
  void _showItemDetailBottomSheet(
      BuildContext context,
      String itemName,
      String itemType,
      String assetImagePath,
      String description,
      int asset_id) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 320,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: assetImagePath.startsWith("http")
                  ? Image.network(
                    assetImagePath,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ):
                  Image.asset(
                    assetImagePath,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                itemName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.category, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    itemType,
                    style: const TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Divider(thickness: 1),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
        searchSection(
          runFilter: (searchValue, ddValue, searchDateone, SearchDatetwo) {
            runFilter(searchValue, ddValue);
          },
          includeDateone: false,
          includeDatetwo: false,
        ),
        isLoading
          ? Expanded(child: Center(child: CircularProgressIndicator(),))
          : filteredAssets.isEmpty
            ? Expanded(child: Center(child: NoResultsWidget(),))
            : Expanded(child: ListView.builder(
              itemCount: filteredAssets.length,
              itemBuilder: (content, index)=> AssetCard(
                    asset_name: filteredAssets[index]["name"],
                    type_string: filteredAssets[index]["type"],
                    status: filteredAssets[index]["status"],
                    img_string: filteredAssets[index]['image_url'] == null
                        ? "images/no-image.webp"
                        : filteredAssets[index]['image_url'],
                    detail_button: true,
                    detailOnPressed: () {
                      _showItemDetailBottomSheet(
                        context,
                        filteredAssets[index]['name'],
                        filteredAssets[index]['type'],
                        filteredAssets[index]['image_url'] == null
                            ? "images/no-image.webp"
                            : filteredAssets[index]['image_url'],
                        filteredAssets[index]['description'] == null
                            ? " - "
                            : filteredAssets[index]['description'],
                        filteredAssets[index]["id"],
                      );
                    },
                  ),
            ))
      ]),
    );
  }
}
