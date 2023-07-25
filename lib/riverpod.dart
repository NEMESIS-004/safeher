// ignore_for_file: non_constant_identifier_names
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
