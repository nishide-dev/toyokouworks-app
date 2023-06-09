import 'package:flutter/material.dart';

class GyroModel extends StatelessWidget {
  const GyroModel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0E1117),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Gyro'),
        backgroundColor: Color(0xff161b22),
      ),
      body: Container(
        child: Center(
          child: Text(
            'Coming Soon...',
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
