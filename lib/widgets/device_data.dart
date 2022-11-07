import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class Device extends StatelessWidget {
  const Device({super.key, required this.device});

  final BluetoothDevice device;
  final bool _connected = false;

  Widget getStatus(connected) {
    return (connected)
        ? const Text('Status: Connected')
        : const Text('Status: Not connected');
  }

  Widget getDeviceName(device) {
    var name = 'Unkown Device';

    if (device.name.isNotEmpty) {
      name = device.device.name;
    }

    return Text('Name: $name');
  }

  Widget getDeviceMacAddress(device) {
    var macAddress = device.id.id;
    return Text('MAC Address: $macAddress');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getDeviceName(device),
        getDeviceMacAddress(device),
        getStatus(_connected),
      ],
    );
  }
}
