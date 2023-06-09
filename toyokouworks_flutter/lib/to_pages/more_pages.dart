import 'package:flutter/material.dart';

class MorePages extends StatelessWidget {
  const MorePages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('More'),
      ),
      body: Container(
        color: Colors.red,
      ),
    );
  }
}
