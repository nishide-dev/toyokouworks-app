import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class SerialPage extends StatelessWidget {
  const SerialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0E1117),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Serial'),
        backgroundColor: Color(0xff161b22),
      ),
      body: SerialModel(),
    );
  }
}

class SerialModel extends StatefulWidget {
  const SerialModel({super.key});

  @override
  State<SerialModel> createState() => _SerialModelState();
}

class _SerialModelState extends State<SerialModel> {
  UsbPort? _port;
  String _status = 'Idle';
  List<Widget> _ports = [];
  List<Widget> _serialData = [];

  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;
  UsbDevice? _device;

  TextEditingController _textController = TextEditingController();

  Future<bool> _connectTo(device) async {
    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }

    if (_transaction != null) {
      _transaction!.dispose();
      _transaction = null;
    }

    if (_port != null) {
      _port!.close();
      _port = null;
    }

    if (device == null) {
      setState(() {
        _status = 'Disconnected';
      });
      return true;
    }

    _port = await device.create();
    if (await (_port!.open()) != true) {
      setState(() {
        _status = 'Failed to open port';
      });
      return true;
    }
    _device = device;

    await _port!.setDTR(true);
    await _port!.setRTS(true);
    await _port!.setPortParameters(
        115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    _transaction = Transaction.stringTerminated(
        _port!.inputStream as Stream<Uint8List>, Uint8List.fromList([13, 10]));

    _subscription = _transaction!.stream.listen((String line) {
      setState(() {
        _serialData.add(Text(line));
        if (_serialData.length > 20) {
          _serialData.removeAt(0);
        }
      });
    });

    setState(() {
      _status = 'Connected';
    });
    return true;
  }

  void _getPorts() async {
    _ports = [];
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (!devices.contains(_device)) {
      _connectTo(null);
    }
    print(devices);

    devices.forEach((device) {
      _ports.add(ListTile(
        leading: Icon(Icons.usb),
        title: Text(device.productName!),
        subtitle: Text(device.manufacturerName!),
        trailing: ElevatedButton(
          child: Text(_device == device ? 'Disconnect' : 'Connect'),
          onPressed: () {
            _connectTo(_device == device ? null : device).then((res) {
              _getPorts();
            });
          },
        ),
      ));
    });

    setState(() {
      print(_ports);
    });
  }

  @override
  void initState() {
    super.initState();

    UsbSerial.usbEventStream!.listen((UsbEvent event) {
      _getPorts();
    });

    _getPorts();
  }

  @override
  void dispose() {
    super.dispose();
    _connectTo(null);
  }

  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Text(
            _ports.length > 0
                ? 'Available Serial Ports'
                : 'No serial devices available',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          ..._ports,
          Text(
            'Status: $_status\n',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          Text(
            'Info: ${_port.toString()}\n',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          ListTile(
            title: TextField(
              controller: _textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Text to Send',
                labelStyle: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            trailing: ElevatedButton(
              child: Text(
                'Send',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              onPressed: _port == null
                  ? null
                  : () async {
                      if (_port == null) {
                        return;
                      }
                      String data = _textController.text + '\r\n';
                      await _port!.write(Uint8List.fromList(data.codeUnits));
                      _textController.text = '';
                    },
            ),
          ),
          Text(
            'Result Data',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          ..._serialData,
        ],
      ),
    );
  }
}
