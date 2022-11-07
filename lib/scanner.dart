import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

import 'widgets/device.dart';

class Scanner extends StatefulWidget {
  Scanner({super.key, required this.title});

  final String title;

  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devices = [];

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  bool _isScanning = false;
  String _buttonText = 'Start';

  _addDevice(final BluetoothDevice device) {
    if (!widget.devices.contains(device)) {
      setState(() {
        widget.devices.add(device);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initBluetoothScanning();
  }

  void initBluetoothScanning() async {
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

    widget.flutterBlue.isScanning.listen((isScanning) {
      _isScanning = isScanning;
    });

    widget.flutterBlue.connectedDevices.asStream().listen((devices) {
      for (BluetoothDevice device in devices) {
        _addDevice(device);
      }
    });

    widget.flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        _addDevice(result.device);
      }
    });
  }

  scan(context) async {
    if (!_isScanning) {
      widget.devices.clear();
      widget.flutterBlue.startScan();

      setState(() {
        _buttonText = 'Stop';
      });
    } else {
      widget.flutterBlue.stopScan();

      setState(() {
        _buttonText = 'Start';
      });
    }
  }

  // ListView _buildView() {
  //   if (_connectedDevice != null) {
  //     return _buildConnectDeviceView();
  //   }
  //   return _buildListViewOfDevices();
  // }

  ListView _buildListViewOfDevices() {
    return ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: widget.devices.length,
        itemBuilder: (BuildContext context, int index) {
          return Device(device: widget.devices[index]);
        },
        separatorBuilder: (BuildContext context, int index) => const Divider());
  }

  // ListView _buildConnectDeviceView() {
  //   return ListView(
  //     padding: const EdgeInsets.all(8),
  //     children: <Widget>[],
  //   );
  // }

  Text getButtonText() {
    return (_isScanning) ? const Text('Stop') : const Text('Start');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _buildListViewOfDevices(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          scan(context);
        },
        label: Text(_buttonText),
        icon: const Icon(Icons.search),
      ),
    );
  }
}
