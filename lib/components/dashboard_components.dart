import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class dashBoardCard extends StatelessWidget {
  String title;
  int count;
  IconData icon;
  Color bg;
  dashBoardCard(
      {super.key,
      required this.title,
      required this.count,
      required this.icon,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 24, color: Colors.white),
                  Text('$count',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white)),
                ],
              ),
              const SizedBox(height: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class barChartCard extends StatelessWidget {
  List<String> assets;
  List<int> asset_q;
  List<Color> colors;
  barChartCard(
      {super.key,
      required this.assets,
      required this.asset_q,
      required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      width: 400,
      height: 250,
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
      child: Column(
        children: [
          Expanded(
            flex: 10,
            child: BarChart(
              BarChartData(
                maxY: asset_q.reduce((a, b) => a > b ? a : b)%2==0? asset_q.reduce((a, b) => a > b ? a : b)+2.toDouble():asset_q.reduce((a, b) => a > b ? a : b)+1.toDouble(),// get the maximum value  and find the nearest 5 divisable number
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10));
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(assets[value.toInt()],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.blueGrey, width: 1)),
                barGroups: List.generate(
                  assets.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                          toY: asset_q[index].toDouble(),
                          color: colors[index],
                          width: 40,
                          borderRadius: BorderRadius.zero)
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Text(
              "Asset Quantities",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class eachPieChart extends StatelessWidget {
  List<String> statuses;
  List<List<int>> status_q;
  List<Color> colors;
  int tab;
  String tabName;
  eachPieChart(
      {super.key,
      required this.statuses,
      required this.status_q,
      required this.colors,
      required this.tab,
      required this.tabName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20,),
        Text(tabName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),),
        Expanded(
          flex: 5,
          child: PieChart(
            PieChartData(
              sections: List.generate(statuses.length, (index) {
                return PieChartSectionData(
                  value: tab == 4
                      ? (status_q[0][index] +
                          status_q[1][index] +
                          status_q[2][index] +
                          status_q[3][index]).toDouble()
                      : status_q[tab][index].toDouble(),
                  color: colors[index],
                  radius: 60,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  title: (tab == 4
                          ? (status_q[0][index] +
                              status_q[1][index] +
                              status_q[2][index] +
                              status_q[3][index])
                          : status_q[tab][index]).toString(),
                );
              }),
              centerSpaceRadius: 50,
            ),
          ),
        ),
        const Expanded(
          flex: 1,
          child: Center(
            child: Text(
              "Asset Distribution",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            statuses.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    color: colors[index],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    statuses[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
