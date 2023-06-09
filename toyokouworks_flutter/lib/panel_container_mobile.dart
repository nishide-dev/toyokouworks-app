import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class MainPanelContainerMobile extends StatefulWidget {
  // const MainPanelContainerMobile({super.key});
  const MainPanelContainerMobile(
      {Key? key, required this.data, required this.info})
      : super(key: key);
  final List data;
  final List info;

  @override
  State<MainPanelContainerMobile> createState() =>
      _MainPanelContainerMobileState();
}

class _MainPanelContainerMobileState extends State<MainPanelContainerMobile> {
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
        padding: const EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width * 0.28,
        height: MediaQuery.of(context).size.width * 0.35,
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
              height: 10,
            ),
            Text(
              widget.info[0],
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.data[1].toString(),
                  style: TextStyle(
                    fontSize: 25,
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
