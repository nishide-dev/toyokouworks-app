import 'package:toyokouworks_flutter/now_charts/chart_test_model.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:mrx_charts/mrx_charts.dart';

class NowCurrentChart extends StatefulWidget {
  const NowCurrentChart({super.key});
  // const NowCurrentChart({Key? key, required this.data}) : super(key: key);
  // final List data;

  @override
  State<NowCurrentChart> createState() => _NowCurrentChartState();
}

class _NowCurrentChartState extends State<NowCurrentChart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0E1117),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Chart'),
        backgroundColor: Color(0xff161b22),
      ),
      body: Container(
        child: Center(
          // child: Text(
          //   'Coming Soon...',
          //   style: TextStyle(
          //       color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          // ),
          child: ChartOfCurrent(data: [
            1.0,
            2.0,
            3.0,
            4.0,
            5.0,
            6.0,
            7.0,
            8.0,
            9.0,
            10.0,
            11.0,
            12.0,
            13.0
          ]),
        ),
      ),
    );
  }
}

class ChartOfCurrent extends StatefulWidget {
  const ChartOfCurrent({Key? key, required this.data}) : super(key: key);
  final List data;
  @override
  State<ChartOfCurrent> createState() => _ChartOfCurrentState();
}

class _ChartOfCurrentState extends State<ChartOfCurrent> {
  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     actions: [
    //       Padding(
    //         padding: const EdgeInsets.only(
    //           right: 20.0,
    //         ),
    //         child: GestureDetector(
    //           onTap: () => setState(() {}),
    //           child: const Icon(
    //             Icons.refresh,
    //             size: 26.0,
    //           ),
    //         ),
    //       ),
    //     ],
    //     // backgroundColor: Colors.transparent,
    //     elevation: 0.0,
    //     title: const Text('Line'),
    //   ),
    //   backgroundColor: const Color(0xFF1B0E41),
    //   body:
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '電流 : ${Random().nextInt(380) + 20}mA',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  '最終計測 : ${DateFormat('h:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(1664005286000))}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Container(
              constraints: const BoxConstraints(
                maxHeight: 400.0,
                maxWidth: 600.0,
              ),
              padding: const EdgeInsets.all(24.0),
              child: Chart(
                layers: layers(widget.data),
                padding: const EdgeInsets.symmetric(horizontal: 30.0).copyWith(
                  bottom: 12.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ChartLayer> layers(data) {
    final from = DateTime(2021, 4, 8, 12, 4);
    final to = DateTime(2021, 4, 8, 12, 32);
    final frequency =
        (to.millisecondsSinceEpoch - from.millisecondsSinceEpoch) / 7.0;
    return [
      ChartHighlightLayer(
        shape: () => ChartHighlightLineShape<ChartLineDataItem>(
          backgroundColor: const Color(0xFF331B6D),
          currentPos: (item) => item.currentValuePos,
          radius: const BorderRadius.all(Radius.circular(8.0)),
          width: 60.0,
        ),
      ),
      ChartAxisLayer(
        settings: ChartAxisSettings(
          x: ChartAxisSettingsAxis(
            frequency: frequency,
            max: to.millisecondsSinceEpoch.toDouble(),
            min: from.millisecondsSinceEpoch.toDouble(),
            textStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10.0,
            ),
          ),
          y: ChartAxisSettingsAxis(
            frequency: 100.0,
            max: 400.0,
            min: 0.0,
            textStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10.0,
            ),
          ),
        ),
        labelX: (value) => DateFormat('')
            .format(DateTime.fromMillisecondsSinceEpoch(value.toInt())),
        labelY: (value) => value.toInt().toString(),
      ),
      ChartLineLayer(
        items: List.generate(
          8,
          (index) => ChartLineDataItem(
            x: (index * frequency) + from.millisecondsSinceEpoch,
            // value: Random().nextInt(380) + 20,
            value: data[index],
          ),
        ),
        settings: const ChartLineSettings(
          color: Color(0xFF8043F9),
          thickness: 4.0,
        ),
      ),
      ChartTooltipLayer(
        shape: () => ChartTooltipLineShape<ChartLineDataItem>(
          backgroundColor: Colors.white,
          circleBackgroundColor: Colors.white,
          circleBorderColor: const Color(0xFF331B6D),
          circleSize: 4.0,
          circleBorderThickness: 2.0,
          currentPos: (item) => item.currentValuePos,
          onTextValue: (item) =>
              '${item.value.toString()}mA\n${DateFormat('h:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(item.x.toInt()))}',
          marginBottom: 6.0,
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 8.0,
          ),
          radius: 6.0,
          textStyle: const TextStyle(
            color: Color(0xFF8043F9),
            letterSpacing: 0.2,
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ];
  }
}