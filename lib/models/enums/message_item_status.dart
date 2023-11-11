enum MessageItemStatus {
  sended(
    value: 'sended',
  ),
  readed(value: 'readed'),
  received(value: 'received');

  final String value;

  const MessageItemStatus({required this.value});

  static MessageItemStatus getEnumOfString(String value) {
    return MessageItemStatus.values.firstWhere((el) => el.value == value);
  }
}
