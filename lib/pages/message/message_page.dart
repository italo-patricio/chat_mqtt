import 'package:chat_mqtt/extensions.dart';
import 'package:chat_mqtt/models/enums/message_item_status.dart';
import 'package:chat_mqtt/models/message_model.dart';
import 'package:chat_mqtt/pages/message/message_controller.dart';
import 'package:flutter/material.dart';

class MessagePage extends StatefulWidget {
  final MessageController controller;
  const MessagePage({super.key, required this.controller});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late final MessageController _controller = widget.controller;

  final TextEditingController _inputControl = TextEditingController();

  Map<String, IconData> messageStateIcons = {
    MessageItemStatus.readed.value: Icons.done_all,
    MessageItemStatus.received.value: Icons.done_all,
    MessageItemStatus.sended.value: Icons.check,
  };

  _MessagePageState();

  @override
  initState() {
    Future.wait([_controller.connect()]);

    final model = MessageModel(
      userFromName: 'ítalo',
      userToName: 'alguem',
      topicFrom: 'chat/italo',
      topicTo: 'chat/alguem',
    );
    _controller.setMessageModel(model);
    super.initState();
  }

  sendMessage() {
    _controller.sendMessage(_inputControl.text);
    _inputControl.clear();
  }

  @override
  void dispose() {
    _inputControl.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            CircleAvatar(
              child: Text(_controller.messageModel?.userToName.characters.first
                      .toUpperCase() ??
                  ''),
            ),
            const SizedBox(width: 8),
            Text(
              _controller.messageModel?.userToName.toTitleCase() ?? '',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, _, w) {
                if (!_controller.connected) {
                  return IconButton(
                    onPressed: () {
                      _controller.connect();
                    },
                    icon: const Icon(
                      Icons.radio_button_off,
                      color: Colors.red,
                    ),
                  );
                }

                return IconButton(
                  onPressed: () {
                    _controller.disconnect();
                  },
                  icon: const Icon(
                    Icons.radio_button_on,
                    color: Colors.green,
                  ),
                );
              })
        ],
      ),
      body: ValueListenableBuilder(
          valueListenable: _controller,
          builder: (context, snapshot, w) {
            return Center(
              child: switch (_controller.value) {
                MessageLoadingState() =>
                  const CircularProgressIndicator.adaptive(),
                MessageOnlineState() => _buildContentOnline(),
                _ => const Text('Offline, favor tente conectar manualmente.')
              },
            );
          }),
    );
  }

  Column _buildContentOnline() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _bodyMessage(),
        const SizedBox(height: 4),
        Container(
          height: 50,
          margin: const EdgeInsets.only(
            bottom: 30,
            left: 6,
            right: 6,
          ),
          padding: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.grey)),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputControl,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Digite alguma mensagem',
                  ),
                ),
              ),
              IconButton(
                onPressed: sendMessage,
                icon: const Icon(Icons.send),
              )
            ],
          ),
        ),
      ],
    );
  }

  _bodyMessage() {
    final reversed = _controller.messages.reversed.toList();
    return Expanded(
      child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(
                height: 10,
              ),
          reverse: true,
          itemCount: _controller.messages.length,
          itemBuilder: (_, i) {
            final item = reversed[i];
            return _buildMessageItem(item);
          }),
    );
  }

  Row _buildMessageItem(Map<String, dynamic> item) {
    return Row(
      mainAxisAlignment: item['from'] == _controller.messageModel?.userFromName
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment:
              item['from'] == _controller.messageModel?.userFromName
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: item['from'] == _controller.messageModel?.userFromName
                    ? const Color.fromRGBO(120, 102, 214, 0.2)
                    : Colors.grey.shade100,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Text(item['message'] ?? ''),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal:
                      _controller.messageModel?.userFromName == item['from']
                          ? 14
                          : 18),
              child: Row(
                children: [
                  Text(
                    item['created_at'] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  if (_controller.messageModel?.userFromName == item['from'])
                    Icon(
                      messageStateIcons[item['status']] ??
                          messageStateIcons[MessageItemStatus.sended.value],
                      size: 12,
                    ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}
