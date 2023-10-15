// ignore_for_file: non_constant_identifier_names
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SheildButton extends StateNotifier<bool> {
  SheildButton() : super(false);

  toogleshieldstate() {
    state = !state;
  }
}

final ShieldStateProvider = StateNotifierProvider<SheildButton, bool>((ref) {
  return SheildButton();
});

class ConnectButton extends StateNotifier<bool> {
  ConnectButton() : super(false);

  toogleconnectionstate() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        state = true;
      }
    } on SocketException catch (_) {
      state = false;
    }
  }
}

final ConStateProvider = StateNotifierProvider<ConnectButton, bool>((ref) {
  return ConnectButton();
});
