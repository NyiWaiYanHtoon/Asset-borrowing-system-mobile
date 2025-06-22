import 'dart:convert';

import 'package:asset_borrowing_system_mobile/common_pages/config.dart';
import 'package:asset_borrowing_system_mobile/components/dashboard_components.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<String> assets = ["Books", "Electronics", "iPads", "Laptops"];
  List<int> asset_q = [0, 0, 0, 0];
  List<String> statuses = ["Availabe", "Waiting", "Disabled", "Borrowed"];

  List<List<int>> status_q = [
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
  ];
  List<IconData> icons = [
    Icons.menu_book_rounded,
    Icons.memory,
    Icons.tablet,
    Icons.laptop
  ];
  List<Color> colors = [
    const Color(0xFF10AD3B),
    const Color(0xFFEE930A),
    const Color(0xFFE01620),
    const Color(0xFF7229AA),
  ];
  void initState() {
    super.initState();
    retrieveDashboardData();
  }

  Map<String, dynamic> user = {};
  Future<void> retrieveDashboardData() async {
    final Uri _uri = Uri.parse("http://${Config.getServerPath()}/getDashboard");
    http.Response response = await http.get(_uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        asset_q = asset_q =
            List.generate(data.length, (index) => data[index]["total_assets"]);
        status_q = List.generate(
            data.length,
            (index) => [
                  int.parse(data[index]["available"]),
                  int.parse(data[index]["waiting"]),
                  int.parse(data[index]["disabled"]),
                  int.parse(data[index]["borrowed"])
                ]);
      });
    } else {
      print("Error: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 150,
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  //List.generate will generate a list of buildCard()
                  assets.length,
                  (index) => dashBoardCard(
                    title: assets[index],
                    count: asset_q[index].toInt(),
                    icon: icons[index],
                    bg: colors[index],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child:
                barChartCard(assets: assets, asset_q: asset_q, colors: colors),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.blueGrey[900],
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 8.0,
                    offset: Offset(0, 4),
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: DefaultTabController(
                length: 5,
                child: Column(
                  children: [
                    TabBar(
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      tabs: [
                        const Tab(
                          text: "All",
                        ),
                        Tab(
                          icon: Icon(icons[0]),
                        ),
                        Tab(
                          icon: Icon(icons[1]),
                        ),
                        Tab(
                          icon: Icon(icons[2]),
                        ),
                        Tab(
                          icon: Icon(icons[3]),
                        ),
                      ],
                    ),
                    Expanded(
                        child: TabBarView(
                      children: [
                        eachPieChart(
                            statuses: statuses,
                            status_q: status_q,
                            colors: colors,
                            tab: 4,
                            tabName: "All Assets"),
                        eachPieChart(
                          statuses: statuses,
                          status_q: status_q,
                          colors: colors,
                          tab: 0,
                          tabName: "Books",
                        ),
                        eachPieChart(
                          statuses: statuses,
                          status_q: status_q,
                          colors: colors,
                          tab: 1,
                          tabName: "Electronics",
                        ),
                        eachPieChart(
                          statuses: statuses,
                          status_q: status_q,
                          colors: colors,
                          tab: 2,
                          tabName: "iPads",
                        ),
                        eachPieChart(
                          statuses: statuses,
                          status_q: status_q,
                          colors: colors,
                          tab: 3,
                          tabName: "Laptops",
                        ),
                      ],
                    ))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
