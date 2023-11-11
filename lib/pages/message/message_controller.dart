import 'dart:convert';

import 'package:chat_mqtt/models/enums/message_item_status.dart';
import 'package:chat_mqtt/models/enums/message_item_type.dart';
import 'package:chat_mqtt/models/message_model.dart';
import 'package:chat_mqtt/services/mqtt_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:mqtt_client/mqtt_client.dart';

abstract class MessageState {}

class MessageInitialState extends MessageState {}

class MessageLoadingState extends MessageState {}

class MessageOnlineState extends MessageState {}

class MessageOfflineState extends MessageState {}

class MessageController extends ValueNotifier {
  final MqttService _service;
  final List<Map<String, dynamic>> messages = [];

  bool connected = false;
  late MessageModel? messageModel;

  setMessageModel(MessageModel model) {
    messageModel = model;
  }

  String? get topicFrom => messageModel?.topicFrom;
  String? get topicTo => messageModel?.topicTo;
  List<String> get topicsSubscribe => [
        '$topicFrom/#',
        '$topicTo/online',
        '$topicTo/offline',
        '$topicTo/read',
      ];

  MessageController(this._service) : super(MessageInitialState()) {
    _service.clientInstance.onConnected = onConnected;
    _service.clientInstance.onDisconnected = onDisconnected;

    _service.clientInstance.onSubscribed = onSubscribed;
    _service.clientInstance.onUnsubscribed = onUnsubscribed;
  }

  onConnected() {
    connected = true;
    value = MessageOnlineState();
    notifyListeners();
  }

  onDisconnected() {
    connected = false;
    value = MessageOfflineState();
    notifyListeners();
  }

  onSubscribed(String? message) {
    sendMessageToBroker(
      topicName: '$topicTo/online',
      message: jsonEncode({
        'from': 'alguem',
        'to': 'italo',
        'message': 'alguem entrou na conversa $message',
      }),
      mqttQos: MqttQos.atLeastOnce,
    );
  }

  onUnsubscribed(String? message) {}

  Future<void> connect() async {
    value = MessageLoadingState();

    await _service.connect();
    subscribe();
    observables();
    notifyListeners();
  }

  disconnect() {
    sendMessageToBroker(
      topicName: '$topicTo/offline',
      message: jsonEncode({
        'from': 'alguem',
        'to': 'italo',
        'message': 'alguem saiu da conversa',
      }),
      mqttQos: MqttQos.atLeastOnce,
    );

    if (kDebugMode) {
      print('EXAMPLE::Unsubscribing');
    }

    if (messageModel?.topicFrom != null) {
      _service.clientInstance.unsubscribe(messageModel!.topicFrom);
    }

    _service.disconnect();
  }

  subscribe() {
    for (var topic in topicsSubscribe) {
      _service.clientInstance
          .subscribe(topic, MqttQos.exactlyOnce)
          ?.changes
          .listen((event) {
        if (kDebugMode) {
          print('SUBSCRIPTION ($topic) CHANGES LISTEN $event');
        }
      });
    }
  }

  observables() {
    _service.clientInstance.updates
        ?.listen((List<MqttReceivedMessage<MqttMessage?>>? messageList) {
      final recMess = messageList![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      if (kDebugMode) {
        print(
            'EXAMPLE::Change notification:: topic is <${messageList[0].topic}>, payload is <-- $pt -->');
      }

      if (pt.isNotEmpty) {
        final messageItem = jsonDecode(pt);

        if (messageItem['type'] != null &&
            messageItem['type'] != MessageItemType.info.value) {
          sendMessageToBroker(
            topicName: '$topicTo/received',
            message: jsonEncode({
              'message_id': '1',
            }),
            mqttQos: MqttQos.exactlyOnce,
          );

          sendMessageToBroker(
            topicName: '$topicTo/read',
            message: jsonEncode({
              'message_id': '1',
            }),
            mqttQos: MqttQos.exactlyOnce,
          );

          // messageItem['status'] = MessageItemStatus.readed.value;

          messages.add(messageItem);
          notifyListeners();
        }
      }
    });

    _service.clientInstance.published?.listen((MqttPublishMessage message) {
      if (kDebugMode) {
        print(
            'EXAMPLE::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
      }
    });
  }

  sendMessage(String message) {
    final messageToSend = {
      'to': messageModel?.userToName ?? '',
      'from': messageModel?.userFromName ?? '',
      'message': message,
      'created_at': DateTime.now().toString(),
      'type': MessageItemType.standard.value,
      'status': MessageItemStatus.sended.value,
    };

    sendMessageToBroker(
      message: const JsonEncoder().convert(messageToSend),
      mqttQos: MqttQos.exactlyOnce,
      topicName: topicTo,
    );

    messages.add(messageToSend);
    notifyListeners();
  }

  void sendMessageToBroker(
      {required String message, required MqttQos mqttQos, String? topicName}) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message.toString());

    _service.clientInstance
        .publishMessage(topicName ?? '', mqttQos, builder.payload!);
  }

  @override
  void dispose() {
    for (var topic in topicsSubscribe) {
      _service.clientInstance.unsubscribe(topic);
    }

    _service.disconnect();
    super.dispose();
  }
}
