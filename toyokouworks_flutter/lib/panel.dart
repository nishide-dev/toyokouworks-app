import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:toyokouworks_flutter/api/api_test_model.dart';
import 'package:toyokouworks_flutter/now_charts/chart_test_model.dart';
import 'package:toyokouworks_flutter/now_charts/now_current.dart';
import 'package:toyokouworks_flutter/panel_container_desktop.dart';
import 'package:toyokouworks_flutter/panel_container_mobile.dart';
import 'package:toyokouworks_flutter/to_pages/gyro_model.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MainPanel extends StatefulWidget {
  MainPanel({Key? key}) : super(key: key);

  @override
  State<MainPanel> createState() => _MainPanelState();
}

class _MainPanelState extends State<MainPanel> {
  Future<ApiResults>? res;
  @override
  void initState() {
    super.initState();
    var request = new LastRequest(type: 'GET_LAST_DATA');
    res = fetchApiResults(request);
    Timer.periodic(
      // 第一引数：繰り返す間隔の時間を設定
      const Duration(seconds: 2),
      // 第二引数：その間隔ごとに動作させたい処理を書く
      (Timer timer) {
        res = fetchApiResults(request);
        setState(() {});
      },
    );
  }

  List<dynamic> _runningData = [
    ['Connected', 25.3],
    ['Lost', 25.3],
    ['BLE', 120],
    ['Serial', 27],
    ['Connected', 120],
    ['Lost', 65.4]
  ];
  var _colorsDict = {
    'Connected': Colors.lightBlue,
    'Lost': Colors.red,
    'BLE': Colors.lightGreen,
    'Serial': Colors.lightGreen,
  };

  // List<dynamic> _containerData = [
  //   ['電流', ChartTestModel(), 'A'],
  //   ['電圧', ApiWidgetTest(), 'V'],
  //   ['電力', NowCurrentChart(), 'W'],
  //   ['速度', NowCurrentChart(), 'km/h'],
  //   ['積算電流', NowCurrentChart(), 'mAh'],
  //   ['予想残量', NowCurrentChart(), '%'],
  // ];

  List<dynamic> _containerData = [
    ['電流', GyroModel(), 'A'],
    ['電圧', GyroModel(), 'V'],
    ['電力', GyroModel(), 'W'],
    ['速度', GyroModel(), 'km/h'],
    ['積算電流', GyroModel(), 'mAh'],
    ['予想残量', GyroModel(), '%'],
  ];
  @override
  Widget build(BuildContext context) {
    bool _isMobile = false;
    if (MediaQuery.of(context).size.width <= 512.0) {
      _isMobile = true;
    }
    print(MediaQuery.of(context).size.width);

    print(_isMobile);
    if (_isMobile) {
      print('mobile');

      return FutureBuilder<ApiResults>(
          future: res,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MainPanelContainerMobile(
                        data: [
                          'Connected',
                          ((double.parse(snapshot.data!.message!['Items'][0]
                                              ['CURRENT']) /
                                          1000) *
                                      1000)
                                  .round() /
                              1000
                        ],
                        info: _containerData[0],
                      ),
                      MainPanelContainerMobile(
                        data: [
                          'Connected',
                          ((double.parse(snapshot.data!.message!['Items'][0]
                                              ['VOLTAGE']) /
                                          1000) *
                                      1000)
                                  .round() /
                              1000
                        ],
                        info: _containerData[1],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MainPanelContainerMobile(
                        data: [
                          'Connected',
                          ((double.parse(snapshot.data!.message!['Items'][0]
                                              ['POWER']) /
                                          1000) *
                                      1000)
                                  .round() /
                              1000
                        ],
                        info: _containerData[2],
                      ),
                      MainPanelContainerMobile(
                        data: [
                          'Connected',
                          double.parse(
                              snapshot.data!.message!['Items'][0]['SPEED'])
                        ],
                        info: _containerData[3],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MainPanelContainerMobile(
                        data: [
                          'Connected',
                          (snapshot.data!.message!['Items'][0]['INTEGRATED'] *
                                      10)
                                  .round() /
                              10
                        ],
                        info: _containerData[4],
                      ),
                      MainPanelContainerMobile(
                        data: [
                          'Connected',
                          (snapshot.data!.message!['Items'][0]['BATTERY'] * 100)
                                  .round() /
                              100
                        ],
                        info: _containerData[5],
                      ),
                    ],
                  ),
                ],
              );
              // } else if (snapshot.hasError) {
              //   return Center(
              //     child: Text("${snapshot.error}"),
              //   );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          });
    } else {
      print('desktop');
      return FutureBuilder<ApiResults>(
          future: res,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MainPanelContainerDesktop(
                        data: [
                          'Connected',
                          ((double.parse(snapshot.data!.message!['Items'][0]
                                              ['CURRENT']) /
                                          1000) *
                                      1000)
                                  .round() /
                              1000
                        ],
                        info: _containerData[0],
                      ),
                      MainPanelContainerDesktop(
                        data: [
                          'Connected',
                          ((double.parse(snapshot.data!.message!['Items'][0]
                                              ['VOLTAGE']) /
                                          1000) *
                                      1000)
                                  .round() /
                              1000
                        ],
                        info: _containerData[1],
                      ),
                      MainPanelContainerDesktop(
                        data: [
                          'Connected',
                          ((double.parse(snapshot.data!.message!['Items'][0]
                                              ['POWER']) /
                                          1000) *
                                      1000)
                                  .round() /
                              1000
                        ],
                        info: _containerData[2],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MainPanelContainerDesktop(
                        data: [
                          'Connected',
                          double.parse(
                              snapshot.data!.message!['Items'][0]['SPEED'])
                        ],
                        info: _containerData[3],
                      ),
                      MainPanelContainerDesktop(
                        data: [
                          'Connected',
                          (snapshot.data!.message!['Items'][0]['INTEGRATED'] *
                                      10)
                                  .round() /
                              10
                        ],
                        info: _containerData[4],
                      ),
                      MainPanelContainerDesktop(
                        data: [
                          'Connected',
                          (snapshot.data!.message!['Items'][0]['BATTERY'] * 100)
                                  .round() /
                              100
                        ],
                        info: _containerData[5],
                      ),
                    ],
                  ),
                ],
              );
              // } else if (snapshot.hasError) {
              //   return Text("${snapshot.error}");
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          });
    }
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
