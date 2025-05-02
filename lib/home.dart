import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChannelMethodsCalling extends StatefulWidget {
  const ChannelMethodsCalling({super.key});

  @override
  State<ChannelMethodsCalling> createState() => _ChannelMethodsCallingState();
}

class _ChannelMethodsCallingState extends State<ChannelMethodsCalling> {
  static const methodChannel =
      MethodChannel('com.example.ch11_method_channel/deviceInfo');
  String _deviceInfo = '';

  Future<void> _getDeviceInfo() async {
    String deviceInfo;
    try {
      deviceInfo = await methodChannel.invokeMethod('getDeviceInfo');
    } on PlatformException catch (e) {
      deviceInfo = 'Failed to get device info: ${e.message}.';
    }
    setState(() {
      _deviceInfo = deviceInfo;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Method Channel'),
      ),
      body: SafeArea(
          child: ListTile(
        title: Text(
          _deviceInfo,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _deviceInfo,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        contentPadding: const EdgeInsets.all(16),
      )),
    );
  }
}
