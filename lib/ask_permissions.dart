import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iot_sensor_reader/app.dart';
import 'package:permission_handler/permission_handler.dart';

class AskPermissions extends StatefulWidget {
  const AskPermissions({super.key});

  @override
  State<AskPermissions> createState() => _AskPermissions();
}

class _AskPermissions extends State<AskPermissions> {
  void _askPermission() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      if (statuses[Permission.bluetoothScan] == PermissionStatus.granted ||
          statuses[Permission.bluetoothConnect] == PermissionStatus.granted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => App())
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Please provide Permissions'),
            MaterialButton(
              child: const Text('Allow Permissions'),
              onPressed: () {
                _askPermission();
              },
            )
          ],
        ),
      ),
    );
  }
}