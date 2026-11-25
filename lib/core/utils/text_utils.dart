/// Normaliza un texto para comparar u ordenar sin importar mayúsculas ni
/// tildes: "Bogotá D.C." -> "bogota d.c.", "Ñuñoa" -> "nunoa".
String normalizarTexto(String texto) {
  const origen = 'áàäâãéèëêíìïîóòöôõúùüûñç';
  const destino = 'aaaaaeeeeiiiiooooouuuunc';

  final buffer = StringBuffer();
  for (final caracter in texto.toLowerCase().split('')) {
    final indice = origen.indexOf(caracter);
    buffer.write(indice >= 0 ? destino[indice] : caracter);
  }
  return buffer.toString();
}
