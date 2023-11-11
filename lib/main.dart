import 'dart:convert';

import 'package:chat_mqtt/extensions.dart';
import 'package:chat_mqtt/models/enums/message_item_status.dart';
import 'package:chat_mqtt/models/enums/message_item_type.dart';
import 'package:chat_mqtt/pages/message/message_controller.dart';
import 'package:chat_mqtt/pages/message_list/message_list_controller.dart';
import 'package:chat_mqtt/services/mqtt_service.dart';
import 'package:chat_mqtt/pages/message/message_page.dart';
import 'package:chat_mqtt/pages/message_list/message_list_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sp = await SharedPreferences.getInstance();

  MqttService mqttService = MqttServiceImpl(
      client: MqttServerClient(
    'broker.emqx.io', // '192.168.100.90',
    'flutter-client-mqtt',
  ));

  runApp(MyApp(
    service: mqttService,
    sharedPreferences: sp,
  ));
}

class MyApp extends StatelessWidget {
  final MqttService service;
  final SharedPreferences sharedPreferences;

  const MyApp({
    super.key,
    required this.service,
    required this.sharedPreferences,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mqtt',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MessageListPage(
            controller: MessageListController(sharedPreferences)),
        '/message': (context) =>
            MessagePage(controller: MessageController(service)),
      },
    );
  }
}
