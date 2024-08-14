import 'package:intl_generator/generate_localized.dart';

class ArbMessages {
  final Map<String, List<String>> metadata;
  final Map<String, Map<String, Message>> messages;

  ArbMessages({
    required this.metadata,
    required this.messages,
  });
}
