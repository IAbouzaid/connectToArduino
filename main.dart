import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BluetoothConnection? connection; //here connection name
  bool isConnected = false;

  void connectToArduino() async {
    try {
      BluetoothDevice device = await FlutterBluetoothSerial.instance
          .getBondedDevices()
          .then((List<BluetoothDevice> bondedDevices) {
        return bondedDevices.firstWhere(
                (device) => device.name == "your bluetooth name here");
      });
      if (device != null) {
        connection = await BluetoothConnection.toAddress(device.address);
        setState(() {
          isConnected = true;
        });
        print('Connected to the device');
        connection!.input!.listen((Uint8List data) {
          print('Data incoming: ${ascii.decode(data)}');
          connection!.output.add(data); // Sending data
          if (ascii.decode(data).contains('!')) {
            connection!.finish(); // Closing connection
            setState(() {
              isConnected = false;
            });
            print('Disconnected by local host');
          }
        }).onDone(() {
          setState(() {
            isConnected = false;
          });
          print('Disconnected by remote request');
        });
      }
    } catch (exception) {
      print('Cannot connect, exception occurred: $exception');
    }
  }

  @override
  void initState() {
    super.initState();
    connectToArduino();
  }
void sendDataToArduino_off(){
  if (isConnected) {
    String message = "0";
    connection!.output.add(Uint8List.fromList(utf8.encode(message)));
    print('Data sent: $message');
  }
}
  void sendDataToArduino_on() {
    if (isConnected) {
      String message = "1";
      connection!.output.add(Uint8List.fromList(utf8.encode(message)));
      print('Data sent: $message');
    }
  }
   @override
  void dispose(){
    super.dispose();
    connection!.close(); // this will close channel between arduino and flutter to be available on next connection
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Bluetooth Test'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                isConnected ? 'Connected' : 'Disconnected',
                style: TextStyle(fontSize: 32),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: connectToArduino,
                child: Text('Connect to Arduino'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: sendDataToArduino_on,
                child: Text('ON'),
              ),
              ElevatedButton(
                onPressed: sendDataToArduino_off,
                child: Text('OFF'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}