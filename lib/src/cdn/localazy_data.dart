import 'package:localazy_sdk/src/arb/arb_messages.dart';
import 'package:localazy_sdk/src/cdn/models/localazy_config.dart';

class LocalazyData {
  final LocalazyConfig config;
  final ArbMessages? messages;

  LocalazyData({
    required this.config,
    required this.messages,
  });
}
