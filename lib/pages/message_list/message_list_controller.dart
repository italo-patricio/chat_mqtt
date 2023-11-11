import 'package:chat_mqtt/models/message_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class MessageListState {}

class MessageListInitialState extends MessageListState {}

class MessageListLoadingState extends MessageListState {}

class MessageListDoneState extends MessageListState {}

class MessageListController extends ValueNotifier {
  final String keyMessages = 'mqtt-local/messages';
  List<MessageModel> messages = [];

  final SharedPreferences sharedPreferences;

  MessageListController(this.sharedPreferences)
      : super(MessageListInitialState());

  loadMessages() async {
    value = MessageListLoadingState();

    messages.addAll(sharedPreferences
            .getStringList(keyMessages)
            ?.map((e) => MessageModel.fromString(e))
            .toList() ??
        []);

    messages = messages.reversed.toList();

    value = MessageListDoneState();

    notifyListeners();
  }

  saveNewMessage(MessageModel model) {
    messages.add(model);
    value = MessageListDoneState();
    notifyListeners();
  }
}
