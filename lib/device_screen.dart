import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;
  
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
                                await characteristic.setNotifyValue(!characteristic.isNotifying);
                                characteristic.value.listen((value) {
                                  print(value);
                                });
                              },
                              child: const Text('Notify'),
                            ),
                            // Column(
                            //   children: characteristic.descriptors
                            //       .map(
                            //         (descriptor) => Text(
                            //             'Descriptor: 0x${descriptor.uuid.toString().toUpperCase()}'),
                            //         //         onReadPressed: () => d.read(),
                            //         // onWritePressed: () => d.write(_getRandomBytes()),
                            //       )
                            //       .toList(),
                            // )
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
        title: Text(device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback? onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => device.connect();
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
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                leading: (snapshot.data == BluetoothDeviceState.connected)
                    ? const Icon(Icons.bluetooth_connected)
                    : const Icon(Icons.bluetooth_disabled),
                title: Text(
                    'Device is ${snapshot.data.toString().split('.')[1]}.'),
                subtitle: Text('${device.id}'),
                trailing: StreamBuilder<bool>(
                  stream: device.isDiscoveringServices,
                  initialData: false,
                  builder: (c, snapshot) => IndexedStack(
                    index: snapshot.data! ? 1 : 0,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => device.discoverServices(),
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
              stream: device.services,
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
}
