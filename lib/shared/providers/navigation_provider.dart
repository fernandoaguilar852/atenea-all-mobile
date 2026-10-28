import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para controlar el índice activo del BottomNavigationBar
final mainScreenIndexProvider = StateProvider<int>((ref) => 2); // Dashboard por defecto
