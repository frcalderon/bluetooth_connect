import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'utils/request.dart' show postHumidity, postTemperature;

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  DeviceScreenState createState() => DeviceScreenState();
}

class DeviceScreenState extends State<DeviceScreen> {
  final String temperatureUUID = "00000000-0000-0000-0000-000000000001";
  final String humidityUUID = "00000000-0000-0000-0000-000000000002";

  String buttonText = 'Notify';

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map((service) => Column(
              children: [
                Text('Service: 0x${service.uuid.toString().toUpperCase()}'),
                Column(
                  children: service.characteristics
                      .map(
                        (characteristic) => Column(
                          children: [
                            Text('Characteristic: ${characteristic.uuid.toString()}'),
                            ElevatedButton(
                              onPressed: () async {
                                await handleEvent(characteristic);
                              },
                              child: const Text('Notify'),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                )
              ],
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: widget.device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback? onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => widget.device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => widget.device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return ElevatedButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .button
                        ?.copyWith(color: Colors.white),
                  ));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: widget.device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                leading: (snapshot.data == BluetoothDeviceState.connected)
                    ? const Icon(Icons.bluetooth_connected)
                    : const Icon(Icons.bluetooth_disabled),
                title: Text(
                    'Device is ${snapshot.data.toString().split('.')[1]}.'),
                subtitle: Text('${widget.device.id}'),
                trailing: StreamBuilder<bool>(
                  stream: widget.device.isDiscoveringServices,
                  initialData: false,
                  builder: (c, snapshot) => IndexedStack(
                    index: snapshot.data! ? 1 : 0,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => widget.device.discoverServices(),
                      ),
                      const IconButton(
                        icon: SizedBox(
                          width: 18.0,
                          height: 18.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.grey),
                          ),
                        ),
                        onPressed: null,
                      )
                    ],
                  ),
                ),
              ),
            ),
            StreamBuilder<List<BluetoothService>>(
              stream: widget.device.services,
              initialData: const [],
              builder: (c, snapshot) {
                return Column(
                  children: _buildServiceTiles(snapshot.data!),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  handleEvent(characteristic) async {
    await characteristic.setNotifyValue(!characteristic.isNotifying);

    setState(() {
      buttonText = (characteristic.isNotifying) ? 'Not Notify' : 'Notify';
    });

    characteristic.value.listen((value) {
      if (!value.isEmpty) {
        if (characteristic.uuid.toString() == temperatureUUID) {
          print("Temperature: ${value[0]}");
          postTemperature(value[0].toString());
        } else if (characteristic.uuid.toString() == humidityUUID) {
          print("Humidity: ${value[0]}");
          postHumidity(value[0].toString());
        }
      }
    });
  }
}
