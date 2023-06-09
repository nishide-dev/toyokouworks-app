// ignore_for_file: prefer_final_fields, prefer_const_constructors

import 'package:animate_do/animate_do.dart';
import 'package:toyokouworks_flutter/panel.dart';
import 'package:toyokouworks_flutter/to_pages/gps_map.dart';
import 'package:toyokouworks_flutter/to_pages/gyro_model.dart';
import 'package:toyokouworks_flutter/to_pages/more_pages.dart';
import 'package:toyokouworks_flutter/to_pages/page_1.dart';
import 'package:toyokouworks_flutter/to_pages/serial.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Expenses extends StatefulWidget {
  const Expenses({Key? key}) : super(key: key);

  @override
  _ExpensesPageState createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<Expenses> {
  bool _isLoaded = false;

  List<dynamic> _services = [
    ['Map', Iconsax.location, Colors.blue],
    ['Gyro', Iconsax.activity, Colors.pink],
    ['Serial', Iconsax.command, Colors.orange],
    ['BLE', Iconsax.bluetooth, Colors.yellow],
    ['More', Iconsax.more, Colors.green],
  ];

  // ignore: prefer_final_fields
  List<dynamic> _transactions = [
    [
      'Amazon',
      'https://img.icons8.com/office/2x/amazon.png',
      '6:25pm',
      '\$8.90'
    ],
    [
      'Cash from ATM',
      'https://img.icons8.com/external-kiranshastry-lineal-color-kiranshastry/2x/external-atm-banking-and-finance-kiranshastry-lineal-color-kiranshastry.png',
      '5:50pm',
      '\$200.00'
    ],
    [
      'Netflix',
      'https://img.icons8.com/color/2x/netflix-desktop-app.png',
      '2:22pm',
      '\$13.99'
    ],
    [
      'App Store',
      'https://img.icons8.com/fluency/2x/apple-app-store.png',
      '6:25pm',
      '\$4.99'
    ],
    [
      'Cash from ATM',
      'https://img.icons8.com/external-kiranshastry-lineal-color-kiranshastry/2x/external-atm-banking-and-finance-kiranshastry-lineal-color-kiranshastry.png',
      '5:50pm',
      '\$200.00'
    ],
    [
      'Netflix',
      'https://img.icons8.com/color/2x/netflix-desktop-app.png',
      '2:22pm',
      '\$13.99'
    ],
  ];

  List<dynamic> _actionPages = [
    ['Map', GPSMap()],
    ['Gyro', GyroModel()],
    ['Serial', SerialPage()],
    ['BLE', GyroModel()],
    ['More', MorePages()]
  ];

  late ScrollController _scrollController;
  bool _isScrolled = false;
  // bool _isConnected = false;
  bool? _isConnected;
  bool? _isBLE;
  bool? _isSerial;
  Future<ApiResults>? res;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_listenToScrollChange);

    _isConnected = false;
    _isBLE = true;
    _isSerial = false;

    var request = new LastRequest(type: 'GET_LAST_DATA');
    res = fetchApiResults(request);

    // set _isLoaded to true after 2 seconds
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoaded = true;
      });
    });

    Timer.periodic(
      // 第一引数：繰り返す間隔の時間を設定
      const Duration(seconds: 3),
      // 第二引数：その間隔ごとに動作させたい処理を書く
      (Timer timer) {
        if (_isBLE! || _isSerial!) {
          _isConnected = true;
        } else {
          _isConnected = false;
        }
        res = fetchApiResults(request);
        // print(_isConnected);
        setState(() {});
      },
    );
  }

  void _listenToScrollChange() {
    if (_scrollController.offset >= MediaQuery.of(context).size.height * 0.4) {
      setState(() {
        _isScrolled = true;
      });
    } else {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _isMobile = false;
    if (MediaQuery.of(context).size.width <= 512.0) {
      _isMobile = true;
    }
    return FutureBuilder<ApiResults>(
      future: res,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.message!['Items'][0]['LAST_TIME'] <
              DateTime.now().millisecondsSinceEpoch) {
            return ExpencesContent(
              controller: _scrollController,
              isRunning: true,
            );
          } else {
            return ExpencesContent(
              controller: _scrollController,
              isRunning: false,
            );
          }
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold));
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  // Charts Data
  List<Color> gradientColors = [
    const Color(0xffe68823),
    const Color(0xffe68823),
  ];

  LineChartData mainData() {
    return LineChartData(
      borderData: FlBorderData(
        show: false,
      ),
      gridData: FlGridData(
          show: true,
          horizontalInterval: 1.6,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              dashArray: const [5, 5],
              color: const Color(0xff37434d).withOpacity(0.2),
              strokeWidth: 9,
            );
          },
          drawVerticalLine: false),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 5,
          interval: 1,
          getTextStyles: (context, value) => const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 8),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return 'MAR';
              case 4:
                return 'JUN';
              case 7:
                return 'SEP';
              case 10:
                return 'OCT';
            }
            return '';
          },
          margin: 5,
        ),
        leftTitles: SideTitles(
          showTitles: false,
          interval: 1,
          getTextStyles: (context, value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '10k';
              case 3:
                return '30k';
              case 5:
                return '50k';
            }
            return '';
          },
          reservedSize: 25,
          margin: 12,
        ),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineTouchData: LineTouchData(
        getTouchedSpotIndicator:
            (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((index) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: Colors.white.withOpacity(0.1),
                strokeWidth: 2,
                dashArray: [3, 3],
              ),
              FlDotData(
                show: false,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 8,
                  color: [
                    Colors.black,
                    Colors.black,
                  ][index],
                  strokeWidth: 2,
                  strokeColor: Colors.black,
                ),
              ),
            );
          }).toList();
        },
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipPadding: const EdgeInsets.all(8),
          tooltipBgColor: Color(0xff2e3747).withOpacity(0.8),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((touchedSpot) {
              return LineTooltipItem(
                '\$${touchedSpot.y.round()}0.00',
                const TextStyle(color: Colors.white, fontSize: 12.0),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
      lineBarsData: [
        LineChartBarData(
          spots: _isLoaded
              ? [
                  FlSpot(0, 3),
                  FlSpot(2.4, 2),
                  FlSpot(4.4, 3),
                  FlSpot(6.4, 3.1),
                  FlSpot(8, 4),
                  FlSpot(9.5, 4),
                  FlSpot(11, 5),
                ]
              : [
                  FlSpot(0, 0),
                  FlSpot(2.4, 0),
                  FlSpot(4.4, 0),
                  FlSpot(6.4, 0),
                  FlSpot(8, 0),
                  FlSpot(9.5, 0),
                  FlSpot(11, 0)
                ],
          isCurved: true,
          colors: gradientColors,
          barWidth: 2,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
              show: true,
              gradientFrom: Offset(0, 0),
              gradientTo: Offset(0, 1),
              colors: [
                Color(0xffe68823).withOpacity(0.1),
                Color(0xffe68823).withOpacity(0),
              ]),
        ),
        LineChartBarData(
          spots: _isLoaded
              ? [
                  FlSpot(0, 4),
                  FlSpot(2.4, 3),
                  FlSpot(4.4, 5),
                  FlSpot(6.4, 3.8),
                  FlSpot(8, 3.8),
                  FlSpot(9.5, 5),
                  FlSpot(11, 5),
                ]
              : [
                  FlSpot(0, 0),
                  FlSpot(2.4, 0),
                  FlSpot(4.4, 0),
                  FlSpot(6.4, 0),
                  FlSpot(8, 0),
                  FlSpot(9.5, 0),
                  FlSpot(11, 0)
                ],
          isCurved: true,
          colors: [
            Color(0xff4e65fe).withOpacity(0.5),
            Color(0xff4e65fe).withOpacity(0),
          ],
          barWidth: 2,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
              show: true,
              gradientFrom: Offset(0, 0),
              gradientTo: Offset(0, 1),
              colors: [
                Colors.blue.withOpacity(0.1),
                Colors.blue.withOpacity(0),
              ]),
        ),
      ],
    );
  }
}

class ExpencesContent extends StatefulWidget {
  const ExpencesContent(
      {Key? key, required this.controller, required this.isRunning})
      : super(key: key);
  final ScrollController controller;
  final bool isRunning;

  @override
  State<ExpencesContent> createState() => _ExpencesContentState();
}

class _ExpencesContentState extends State<ExpencesContent> {
  List<dynamic> _services = [
    ['Map', Iconsax.location, Colors.blue],
    ['Gyro', Iconsax.activity, Colors.pink],
    ['Serial', Iconsax.command, Colors.orange],
    ['BLE', Iconsax.bluetooth, Colors.yellow],
    ['More', Iconsax.more, Colors.green],
  ];

  List<dynamic> _actionPages = [
    ['Map', GPSMap()],
    ['Gyro', GyroModel()],
    ['Serial', SerialPage()],
    ['BLE', GyroModel()],
    ['More', MorePages()]
  ];

  late ScrollController _scrollController;

  bool _isScrolled = false;
  bool _isLoaded = false;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_listenToScrollChange);
    // set _isLoaded to true after 2 seconds
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _isLoaded = true;
      });
    });

    Timer.periodic(
      // 第一引数：繰り返す間隔の時間を設定
      const Duration(seconds: 1),
      // 第二引数：その間隔ごとに動作させたい処理を書く
      (Timer timer) {
        setState(() {});
      },
    );
  }

  void _listenToScrollChange() {
    if (_scrollController.offset >= MediaQuery.of(context).size.height * 0.4) {
      setState(() {
        _isScrolled = true;
      });
    } else {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _isMobile = false;
    if (MediaQuery.of(context).size.width <= 512.0) {
      _isMobile = true;
    }
    return Scaffold(
      backgroundColor: Color(0xff0E1117),
      body: CustomScrollView(
        controller: widget.controller,
        slivers: [
          SliverAppBar(
            expandedHeight: widget.isRunning
                ? MediaQuery.of(context).size.height * (_isMobile ? 0.9 : 1.0)
                : 50,
            elevation: 0,
            // pinned: true,
            stretch: true,
            toolbarHeight: 50,
            backgroundColor: Color(0xff161b22),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            )),
            centerTitle: true,
            title: AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              // opacity: _isScrolled ? 1.0 : 0,
              opacity: 1.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "TOYOKOU WORKS",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 4,
                    width: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade800),
                  )
                ],
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              titlePadding: EdgeInsets.only(bottom: 20),
              title: AnimatedOpacity(
                duration: Duration(milliseconds: 400),
                opacity: _isScrolled ? 0.0 : 1.0,
                child: FadeIn(
                  duration: Duration(milliseconds: 3000),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height *
                            (widget.isRunning ? 0.54 : 0.0),
                        margin:
                            EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        // color: Colors.white,
                        child: MainPanel(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: 20),
              Container(
                height: 115,
                width: double.infinity,
                padding: EdgeInsets.only(top: 20),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    return FadeInDown(
                      delay: Duration(milliseconds: index * 10),
                      duration: Duration(milliseconds: (index + 1) * 10),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        _actionPages[index][1]));
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Color(0xff161B22),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Icon(
                                    _services[index][1],
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                _services[index][0],
                                style: const TextStyle(
                                    color: Colors.blueGrey, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ]),
          ),
        ],
      ),
    );
  }
}

class ApiResults {
  final Map<String, dynamic>? message;
  ApiResults({
    this.message,
  });
  factory ApiResults.fromJson(Map<String, dynamic> json) {
    return ApiResults(
      message: json,
    );
  }
}

Future<ApiResults> fetchApiResults(requestedModel) async {
  Uri url = Uri.parse(dotenv.get('API_URL'));
  var request = requestedModel;
  final response = await http.post(url,
      body: json.encode(request.toJson()),
      headers: {"Content-Type": "application/json"});
  if (response.statusCode == 200) {
    print('success');
    return ApiResults.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed');
  }
}

class SampleRequest {
  // final int? id;
  final String? name;
  SampleRequest({
    // this.id,
    this.name,
  });
  Map<String, dynamic> toJson() => {
        // 'id': id,
        'OperationType': name,
      };
}

class LastRequest {
  final String? type;
  LastRequest({
    this.type,
  });
  Map<String, dynamic> toJson() => {
        'OperationType': type,
      };
}

class PutRequest {
  final String? type;
  final List? data;
  PutRequest({
    this.type,
    this.data,
  });
  Map<String, dynamic> toJson() => {
        'OperationType': type,
        'Data': data,
      };
}
