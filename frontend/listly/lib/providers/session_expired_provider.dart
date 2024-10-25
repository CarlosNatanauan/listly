import 'package:flutter_riverpod/flutter_riverpod.dart';

// This StateProvider holds a boolean value to indicate if the session is expired
final sessionExpiredProvider = StateProvider<bool>((ref) => false);
