enum MessageItemType {
  info('info'),
  standard('satandard');

  final String value;

  const MessageItemType(this.value);

  static MessageItemType getEnumOfString(String value) {
    return MessageItemType.values.firstWhere((el) => el.value == value);
  }
}
