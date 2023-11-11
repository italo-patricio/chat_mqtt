import 'dart:async';

import 'package:chat_mqtt/models/message_model.dart';
import 'package:chat_mqtt/pages/message_list/message_list_controller.dart';
import 'package:flutter/material.dart';

class MessageListPage extends StatefulWidget {
  final MessageListController controller;

  const MessageListPage({super.key, required this.controller});

  @override
  State<MessageListPage> createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  late final MessageListController _controller = widget.controller;

  @override
  void initState() {
    Future.wait(<Future>[_controller.loadMessages()]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: showDialogAddMessage,
              icon: const Icon(Icons.add_comment_rounded)),
        ],
      ),
      body: ValueListenableBuilder(
          valueListenable: _controller,
          builder: (context, snapshot, w) {
            if (_controller.messages.isEmpty) {
              return const Center(
                child: Text('Nada para exibir adicione alguma conexão'),
              );
            }

            return ListView.builder(
                itemCount: _controller.messages.length,
                itemBuilder: (_, i) {
                  final item = _controller.messages[i];
                  return ListTile(
                    leading: CircleAvatar(
                      child:
                          Text(item.userToName.characters.first.toUpperCase()),
                    ),
                    title: Text(item.userToName),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => openMessage(context, item),
                  );
                });
          }),
    );
  }

  void showDialogAddMessage() {
    final model = MessageModel(
      userFromName: 'ítalo',
      userToName: 'alguem',
      topicFrom: 'chat/italo',
      topicTo: 'chat/alguem',
    );

    _controller.saveNewMessage(model);
  }

  openMessage(context, MessageModel modelSelected) {
    Navigator.pushNamed(
      context,
      '/message',
      arguments: modelSelected,
    );
  }
}
