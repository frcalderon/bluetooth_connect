import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

import 'widgets/device.dart';

void main() {
  runApp(const MyApp());
}

checkPerm() async {
  var status = await Permission.bluetooth.status;
  if (status.isDenied) {
    await Permission.bluetooth.request();
  }

  if (await Permission.bluetooth.status.isPermanentlyDenied) {
    openAppSettings();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const title = 'Flutter + Bluetooth';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> scanResutls = [];
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    initBluetoothScanning();
  }

  Future<void> initBluetoothScanning() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();
      if (statuses[Permission.bluetoothScan] != PermissionStatus.granted ||
          statuses[Permission.bluetoothConnect] != PermissionStatus.granted) {
        return;
      }
    }

    flutterBlue.isScanning.listen((isScanning) {
      _isScanning = isScanning;
    });
    
    setState(() {
      
    });
  }

  scan() async {
    if (!_isScanning) {
      scanResutls.clear();
      flutterBlue.startScan(timeout: const Duration(seconds: 4));

      flutterBlue.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (!scanResutls.contains(result.device)) {
            scanResutls.add(result.device);
          }
        }
        setState(() {
          
        });
      });
    } else {
      flutterBlue.stopScan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: scanResutls.length,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                  child: Center(
                    // child: bluetoothDevice(scanResutls[index]),
                    child: Column(
                      children: [
                        Device(device: scanResutls[index])
                      ]
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) => const Divider())),
      floatingActionButton: FloatingActionButton(
        onPressed: scan,
        tooltip: 'Increment',
        child: const Icon(Icons.search),
      ),
    );
  }
}
