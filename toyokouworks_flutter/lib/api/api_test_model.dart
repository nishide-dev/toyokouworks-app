import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiWidgetTest extends StatefulWidget {
  ApiWidgetTest({Key? key}) : super(key: key);

  @override
  _ApiWidgetTestState createState() => _ApiWidgetTestState();
}

class _ApiWidgetTestState extends State<ApiWidgetTest> {
  Future<ApiResults>? res;
  @override
  void initState() {
    super.initState();
    var request = new SampleRequest(name: 'QUERY_DATA');
    res = fetchApiResults(request);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0E1117),
      appBar: AppBar(
        centerTitle: true,
        title: Text('ApiTest'),
        backgroundColor: Color(0xff161b22),
      ),
      body: Container(
        child: Center(
          child: FutureBuilder<ApiResults>(
            future: res,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                    snapshot.data!.message!['Items'][0]['TIME'].toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold));
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold));
              }
              return CircularProgressIndicator();
            },
          ),
        ),
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
