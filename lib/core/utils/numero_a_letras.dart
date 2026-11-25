/// Convierte un valor monetario a texto en español, en mayúsculas.
///
/// Ejemplos:
///   168000  -> "CIENTO SESENTA Y OCHO MIL PESOS"
///   1000000 -> "UN MILLÓN DE PESOS"
///   1       -> "UN PESO"
///   21500   -> "VEINTIÚN MIL QUINIENTOS PESOS"
///
/// No se manejan centavos: el valor se redondea al peso más cercano.
String numeroALetras(double valor) {
  final redondeado = valor.round();
  final esNegativo = redondeado < 0;
  final n = redondeado.abs();

  if (n == 0) return 'CERO PESOS';

  // Límite razonable (miles de millones); más allá se muestra el número
  if (n > 999999999999) return '$n PESOS';

  final millones = n ~/ 1000000;
  final resto = n % 1000000;

  final partes = <String>[];

  if (millones > 0) {
    if (millones == 1) {
      partes.add('UN MILLÓN');
    } else {
      partes.add('${_hasta999999(millones)} MILLONES');
    }
  }

  if (resto > 0) {
    partes.add(_hasta999999(resto));
  }

  var texto = partes.join(' ');

  // Millones exactos llevan "DE": "UN MILLÓN DE PESOS"
  if (resto == 0) {
    texto = '$texto DE PESOS';
  } else if (n == 1) {
    texto = '$texto PESO';
  } else {
    texto = '$texto PESOS';
  }

  return esNegativo ? 'MENOS $texto' : texto;
}

const List<String> _unidades = [
  '',
  'UN',
  'DOS',
  'TRES',
  'CUATRO',
  'CINCO',
  'SEIS',
  'SIETE',
  'OCHO',
  'NUEVE',
  'DIEZ',
  'ONCE',
  'DOCE',
  'TRECE',
  'CATORCE',
  'QUINCE',
  'DIECISÉIS',
  'DIECISIETE',
  'DIECIOCHO',
  'DIECINUEVE',
  'VEINTE',
  'VEINTIÚN',
  'VEINTIDÓS',
  'VEINTITRÉS',
  'VEINTICUATRO',
  'VEINTICINCO',
  'VEINTISÉIS',
  'VEINTISIETE',
  'VEINTIOCHO',
  'VEINTINUEVE',
];

const List<String> _decenas = [
  '',
  '',
  '',
  'TREINTA',
  'CUARENTA',
  'CINCUENTA',
  'SESENTA',
  'SETENTA',
  'OCHENTA',
  'NOVENTA',
];

const List<String> _centenas = [
  '',
  'CIENTO',
  'DOSCIENTOS',
  'TRESCIENTOS',
  'CUATROCIENTOS',
  'QUINIENTOS',
  'SEISCIENTOS',
  'SETECIENTOS',
  'OCHOCIENTOS',
  'NOVECIENTOS',
];

/// Convierte de 1 a 99
String _hasta99(int n) {
  if (n < 30) return _unidades[n];
  final d = n ~/ 10;
  final u = n % 10;
  return u == 0 ? _decenas[d] : '${_decenas[d]} Y ${_unidades[u]}';
}

/// Convierte de 1 a 999
String _hasta999(int n) {
  if (n == 100) return 'CIEN';
  final c = n ~/ 100;
  final r = n % 100;
  final partes = <String>[];
  if (c > 0) partes.add(_centenas[c]);
  if (r > 0) partes.add(_hasta99(r));
  return partes.join(' ');
}

/// Convierte de 1 a 999.999 ("MIL", "VEINTIÚN MIL", "CIENTO UN MIL"...)
String _hasta999999(int n) {
  final miles = n ~/ 1000;
  final r = n % 1000;
  final partes = <String>[];

  if (miles > 0) {
    partes.add(miles == 1 ? 'MIL' : '${_hasta999(miles)} MIL');
  }
  if (r > 0) {
    partes.add(_hasta999(r));
  }
  return partes.join(' ');
}
