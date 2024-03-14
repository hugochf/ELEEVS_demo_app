import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:typed_data/typed_buffers.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

Random random = Random();
int randomNumber = random.nextInt(101);

class MQTTClientManager {
  MqttServerClient client = MqttServerClient.withPort(
      '34.96.156.219', 'app' + randomNumber.toString(), 1883);

  Future<int> connect() async {
    client.logging(on: true);
    client.keepAlivePeriod = 60;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;

    final connMessage = MqttConnectMessage()
        .startClean()
        .withWillQos(MqttQos.atLeastOnce)
        .withClientIdentifier("client-3");
    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      print('MQTTClient::Client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      print('MQTTClient::Socket exception - $e');
      client.disconnect();
    }

    return 0;
  }

  void disconnect() {
    client.disconnect();
  }

  void subscribe(String topic) {
    client.subscribe(topic, MqttQos.atLeastOnce);
  }

  void onConnected() {
    print('MQTTClient::Connected');
  }

  void onDisconnected() {
    print('MQTTClient::Disconnected');
  }

  void onSubscribed(String topic) {
    print('MQTTClient::Subscribed to topic: $topic');
  }

  void pong() {
    print('MQTTClient::Ping response received');
  }

  Uint8List hexToBytes(String hexString) {
    List<int> bytes = <int>[];
    for (int i = 0; i < hexString.length; i += 2) {
      String hex = hexString.substring(i, i + 2);
      bytes.add(int.parse(hex, radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

  void publishMessage(String topic, String hexString) {
    //void publishMessage(String topic, String message) {
    // final builder = MqttClientPayloadBuilder();
    // builder.addString(message);
    // client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);

    Uint8List byteArray = hexToBytes(hexString);
    Uint8Buffer dataBuffer = Uint8Buffer();
    dataBuffer.addAll(byteArray);

    client.publishMessage(topic, MqttQos.exactlyOnce, dataBuffer);
  }

  //Stream<List<MqttReceivedMessage<MqttMessage>>>? getMessagesStream() {
  Stream<List<MqttReceivedMessage<MqttMessage>>> getMessagesStream() {
    return client.updates!;
  }
}
