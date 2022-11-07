import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class Device extends StatefulWidget {
  const Device({super.key, required this.device});

  final BluetoothDevice device;

  @override
  State<Device> createState() => _DeviceState();
}

class _DeviceState extends State<Device> {
  bool _connected = false;
  // List<BluetoothService> _services = [];
  // var _connection;

  Future<void> connect() async {
    // try {
    //   await widget.device.connect();
    // } catch (e) {
    //   rethrow;
    // } finally {
    //   _services = await widget.device.discoverServices();
    //   print(_services);
    // }
    

    setState(() {
      // _connection = widget.device.device.connect();
      _connected = true;
    });
  }

  Widget getStatus(connected) {
    return (connected)
        ? const Text('Status: Connected')
        : const Text('Status: Not connected');
  }

  Widget getDeviceName(device) {
    var name = 'Unkown Device';

    if (device.name.isNotEmpty) {
      name = device.name;
    }

    return Text('Name: $name');
  }

  Widget getDeviceMacAddress(device) {
    var macAddress = device.id.id;
    return Text('MAC Address: $macAddress');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getDeviceName(widget.device),
            getDeviceMacAddress(widget.device),
            getStatus(_connected),
          ],
        ),
        ElevatedButton(
          onPressed: connect,
          child: const Text('Connect'),
        ),
      ],
    );
  }
}
