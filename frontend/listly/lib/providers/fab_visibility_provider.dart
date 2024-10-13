import 'package:flutter_riverpod/flutter_riverpod.dart';

final fabVisibilityProvider =
    StateNotifierProvider<FABVisibilityNotifier, bool>((ref) {
  return FABVisibilityNotifier();
});

class FABVisibilityNotifier extends StateNotifier<bool> {
  FABVisibilityNotifier() : super(true); // FAB is visible by default

  void show() => state = true;
  void hide() => state = false;
}
