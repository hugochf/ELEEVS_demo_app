import 'MQTTClientManager.dart';
import 'aes.dart' as aes;
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:typed_data/typed_buffers.dart';
import "package:hex/hex.dart";

MQTTClientManager mqttClientManager = MQTTClientManager();
const String pubTopic = "J23P000047S2C";
const String subTopic = "J23P000047C2S";

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
