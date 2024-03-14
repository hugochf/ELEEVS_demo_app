import 'package:flutter/material.dart';
import '../MQTTClientManager.dart';
import '../aes.dart' as aes;
import '../commands.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:typed_data/typed_buffers.dart';
import "package:hex/hex.dart";

//////////////////////////////////////////////////////////////////////////////
/// MQTT conection init
MQTTClientManager mqttClientManager = MQTTClientManager();
const String pubTopic = "J23P000054S2C";
const String subTopic = "J23P000054C2S";

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    setupMqttClient();
    setupUpdatesListener();
    super.initState();
  }

  //////////////////////////////////////////////////////////////////////////////
  /// Handle buttons actions
  void _setOn() {
    mqttClientManager.publishMessage(
        pubTopic, aes.msgEnc(stringToHex(Commands.on)));
    setState(() {});
  }

  void _setOff() {
    mqttClientManager.publishMessage(
        pubTopic, aes.msgEnc(stringToHex(Commands.off)));
    setState(() {});
  }

  //////////////////////////////////////////////////////////////////////////////
  /// App body parts
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _setOn();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(MediaQuery.of(context).size.width / 2,
                    MediaQuery.of(context).size.width / 2),
              ),
              child: const Text('ON',
                  style: TextStyle(fontSize: 48, color: Colors.white)),
            ),
            const SizedBox(height: 16), // Spacer between buttons
            ElevatedButton(
              onPressed: () {
                _setOff();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(MediaQuery.of(context).size.width / 2,
                    MediaQuery.of(context).size.width / 2),
              ),
              child: const Text('OFF',
                  style: TextStyle(fontSize: 48, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////////////////////////////
  /// Handle MQTT disconnection
  @override
  void dispose() {
    mqttClientManager.disconnect();
    super.dispose();
  }
}

////////////////////////////////////////////////////////////////////////////////
/// MQTT handling functions
/////////////////////////////////////////////////////////////////////////////
/// Handle the Incomming MQTT message and conversions
String stringToHex(String input) {
  String output = input.codeUnits
      .map((unit) => unit.toRadixString(16).padLeft(2, '0'))
      .join();
  while (output.length % 32 != 0) {
    output += "0";
  }
  return (output);
}

String bytesToHex(Uint8List bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

Uint8List serializeObjectStructure(Object input) {
  final result = Uint8Buffer();
  return Uint8List.fromList(result);
}

String hexToString(String hexString) {
  List<int> bytes = HEX.decode(hexString);
  String resultString = utf8.decode(bytes);
  return resultString;
}

void setupUpdatesListener() {
  mqttClientManager
      .getMessagesStream()
      .listen((List<MqttReceivedMessage<MqttMessage>> c) {
    final recMess = c[0].payload as MqttPublishMessage;
    Uint8Buffer dataBuffer = Uint8Buffer();
    dataBuffer.addAll(recMess.payload.message);
    String msg = bytesToHex(Uint8List.fromList(dataBuffer));
    String decMsg = aes.msgDec(msg);
    String convertedMsg = hexToString(decMsg);
    print(
        'MQTTClient::Message received on topic: <${c[0].topic}> is $decMsg\n');
    print('Converted Message received $convertedMsg\n');
  });
}

//////////////////////////////////////////////////////////////////////////////
/// Handle MQTT connection and Topic subscribe
Future<void> setupMqttClient() async {
  await mqttClientManager.connect();
  mqttClientManager.subscribe(subTopic);
}
