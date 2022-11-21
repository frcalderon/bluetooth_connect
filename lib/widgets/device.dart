import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:iot_sensor_reader/device_screen.dart';

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

  connect() {
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

    return DeviceScreen(device: widget.device);
  }

  Widget getStatus(connected) {
    return (connected)
        ? const Text('Status: Connected')
        : const Text('Status: Not connected');
  }

  Widget getDeviceName() {
    var name = 'Unkown Device';

    if (widget.device.name.isNotEmpty) {
      name = widget.device.name;
    }

    return Text('Name: $name');
  }

  Widget getDeviceMacAddress() {
    var macAddress = widget.device.id.id;
    return Text('MAC Address: $macAddress');
  }

  Widget getConnectButton(context) {
    return StreamBuilder<BluetoothDeviceState>(
        stream: widget.device.state,
        initialData: BluetoothDeviceState.connecting,
        builder: (c, snapshot) {
          VoidCallback? onPressed;
          String text;
          switch (snapshot.data) {
            case BluetoothDeviceState.connected:
              onPressed = () => widget.device.disconnect();
              text = 'Disconnect';
              break;
            case BluetoothDeviceState.disconnected:
              onPressed = () => {
                    widget.device.connect(),
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeviceScreen(
                          device: widget.device,
                        ),
                      ),
                    )
                  };
              text = 'Connect';
              break;
            default:
              onPressed = null;
              text = snapshot.data.toString().substring(21).toUpperCase();
              break;
          }

          return ElevatedButton(onPressed: onPressed, child: Text(text));
        });
  }

  Widget getDeviceServices() {
    return Column();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getDeviceName(),
            getDeviceMacAddress(),
            // getStatus(_connected),
          ],
        ),
        getConnectButton(context),
      ],
    );
  }
}
