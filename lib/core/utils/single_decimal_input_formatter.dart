import 'package:flutter/services.dart';

/// Formatter que permite escribir solo números y un único separador decimal
/// (punto o coma). Al enviar al servicio se usa punto: ver [parseDecimal].
class SingleDecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Solo dígitos, punto y coma
    if (!RegExp(r'^[0-9.,]*$').hasMatch(text)) {
      return oldValue;
    }

    // Máximo un separador decimal (. o ,)
    final separadores = '.'.allMatches(text).length + ','.allMatches(text).length;
    if (separadores > 1) {
      return oldValue;
    }

    return newValue;
  }
}

/// Convierte el texto de un campo numérico a double aceptando coma o punto.
/// Devuelve null si no es un número válido.
double? parseDecimal(String text) {
  return double.tryParse(text.trim().replaceAll(',', '.'));
}

/// Formatea un double sin decimales sobrantes: 3.0 -> "3", 2.5 -> "2.5"
String formatDecimal(double value) {
  return value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toString();
}
