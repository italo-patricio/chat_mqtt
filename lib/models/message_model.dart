import 'dart:convert';

class MessageModel {
  final String userFromName;
  final String userToName;
  final String topicTo;
  final String topicFrom;

  MessageModel({
    required this.userFromName,
    required this.userToName,
    required this.topicFrom,
    required this.topicTo,
  });

  factory MessageModel.fromString(String valueString) {
    return MessageModel.fromJson(jsonDecode(valueString));
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      userFromName: json['userFromName'],
      userToName: json['userToName'],
      topicFrom: json['topicFrom'],
      topicTo: json['topicTo'],
    );
  }

  @override
  String toString() {
    return jsonEncode({
      'userFromName': userFromName,
      'userToName': userToName,
      'topicFrom': topicFrom,
      'topicTo': topicTo,
    })
      ..toString();
  }
}
