import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class MainPanelContainerDesktop extends StatefulWidget {
  // const MainPanelContainerDesktop({super.key});
  const MainPanelContainerDesktop(
      {Key? key, required this.data, required this.info})
      : super(key: key);
  final List data;
  final List info;

  @override
  State<MainPanelContainerDesktop> createState() =>
      _MainPanelContainerDesktopState();
}

class _MainPanelContainerDesktopState extends State<MainPanelContainerDesktop> {
  var _colorsDict = {
    'Connected': Colors.lightBlue,
    'Lost': Colors.red,
    'BLE': Colors.lightGreen,
    'Serial': Colors.lightGreen,
  };
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('Tapped!');
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => widget.info[1]));
      },
      behavior: HitTestBehavior.deferToChild,
      child: Container(
        padding:
            const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
        width: MediaQuery.of(context).size.width * 0.2,
        height: MediaQuery.of(context).size.width * 0.10,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 0, 1, 4),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _colorsDict[widget.data[0]],
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  widget.data[0],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              widget.info[0],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.data[1].toString(),
                  style: TextStyle(
                    fontSize: 23,
                  ),
                ),
                Text(
                  widget.info[2],
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
