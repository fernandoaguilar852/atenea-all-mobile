import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/utils/numero_a_letras.dart';
import '../../domain/entities/cotizacion_impresion_entity.dart';

/// Genera el PDF de una cotización con el mismo diseño de la vista web.
///
/// Es código Dart puro (solo `pdf` e `intl`): recibe la entidad y devuelve los
/// bytes del documento. El logo llega ya descargado para no depender de la red.
class CotizacionPdfGenerator {
  CotizacionPdfGenerator._();

  // ---------------------------------------------------------------------------
  // Medidas (en puntos, hoja carta vertical)
  // ---------------------------------------------------------------------------
  static const double _anchoMarco = 537;
  static const double _anchoInterior = 510;
  static const double _margenH = 37.5;
  static const double _margenV = 28.5;
  static const double _paddingMarco = 12;
  static const double _bordeMarco = 1.2;

  static const double _altoCuerpoTabla = 111;
  static const double _altoFila = 6.2;

  /// Hasta esta cantidad de líneas el formulario cabe en una sola hoja, igual
  /// que en la web. Con más, la tabla continúa en las páginas siguientes.
  static const int _maxLineasUnaPagina = 16;

  // Anchos de columna: CANT, REF, DESCRIPCIÓN, VR. UNI, DCTO., % IVA, TOTAL
  static const Map<int, pw.TableColumnWidth> _columnas = {
    0: pw.FixedColumnWidth(28),
    1: pw.FixedColumnWidth(36),
    2: pw.FixedColumnWidth(275),
    3: pw.FixedColumnWidth(48),
    4: pw.FixedColumnWidth(36),
    5: pw.FixedColumnWidth(31),
    6: pw.FixedColumnWidth(50),
  };

  // ---------------------------------------------------------------------------
  // Colores
  // ---------------------------------------------------------------------------
  static final PdfColor _azulOscuro = PdfColor.fromInt(0xFF0B3C70);
  static final PdfColor _azulTexto = PdfColor.fromInt(0xFF1F4E79);
  static final PdfColor _azulBorde = PdfColor.fromInt(0xFF2E5C8A);
  static final PdfColor _azulClaro = PdfColor.fromInt(0xFFDCE6F2);
  static final PdfColor _azulNumero = PdfColor.fromInt(0xFF1F3864);
  static final PdfColor _grisLinea = PdfColor.fromInt(0xFF9A9A9A);
  static final PdfColor _grisMarca = PdfColor.fromInt(0xFFD9D9D9);
  static final PdfColor _grisTexto = PdfColor.fromInt(0xFF333333);

  // Helvetica estándar no trae la raya larga (—): se usa un guion
  static const String _vacio = '-';

  static const String _textoLegal =
      'Esta cotización tiene una validez establecida. Los precios están '
      'sujetos a cambios sin previo aviso una vez vencida la fecha de '
      'validez. Los impuestos pueden variar según la legislación vigente.';

  /// Genera los bytes del PDF.
  ///
  /// [logo] es opcional (si es null no se dibuja). [expedicion] es el momento
  /// de generación del documento; por defecto, ahora.
  static Future<Uint8List> generar(
    CotizacionImpresionEntity cotizacion, {
    pw.ImageProvider? logo,
    DateTime? expedicion,
  }) async {
    final fechaExpedicion = expedicion ?? DateTime.now();

    final doc = pw.Document(
      title: 'Cotización ${cotizacion.numeroCotizacion}',
      author: cotizacion.empresaNombre,
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      ),
    );

    final unaPagina = cotizacion.lineas.length <= _maxLineasUnaPagina;

    if (unaPagina) {
      // Igual que la web: formulario con marco ajustado al contenido
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.letter,
          margin: const pw.EdgeInsets.fromLTRB(
              _margenH, _margenV, _margenH, _margenV),
          build: (context) => pw.Align(
            alignment: pw.Alignment.topLeft,
            child: pw.SizedBox(
              width: _anchoMarco,
              child: pw.Container(
                padding: const pw.EdgeInsets.all(_paddingMarco),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: _bordeMarco),
                ),
                child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: _contenido(
                    cotizacion,
                    logo: logo,
                    expedicion: fechaExpedicion,
                    rellenarTabla: true,
                    pagina: (_) => 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // Muchas líneas: la tabla continúa en las páginas siguientes
      const margenExtra = _paddingMarco + _bordeMarco;
      doc.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.letter,
            margin: const pw.EdgeInsets.fromLTRB(
              _margenH + margenExtra,
              _margenV + margenExtra,
              _margenH + margenExtra,
              _margenV + margenExtra,
            ),
            buildBackground: (context) => pw.FullPage(
              ignoreMargins: true,
              child: pw.Padding(
                padding: const pw.EdgeInsets.fromLTRB(
                    _margenH, _margenV, _margenH, _margenV),
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border:
                        pw.Border.all(color: PdfColors.black, width: _bordeMarco),
                  ),
                ),
              ),
            ),
          ),
          build: (context) => _contenido(
            cotizacion,
            logo: logo,
            expedicion: fechaExpedicion,
            rellenarTabla: false,
            pagina: (ctx) => ctx.pageNumber,
            context: context,
          ),
        ),
      );
    }

    return doc.save();
  }

  // ---------------------------------------------------------------------------
  // Secciones
  // ---------------------------------------------------------------------------

  static List<pw.Widget> _contenido(
    CotizacionImpresionEntity c, {
    required pw.ImageProvider? logo,
    required DateTime expedicion,
    required bool rellenarTabla,
    required int Function(pw.Context) pagina,
    pw.Context? context,
  }) {
    return [
      _encabezado(c, logo),
      pw.SizedBox(height: 7),
      _clienteYFechas(c),
      pw.SizedBox(height: 3),
      _tabla(c, rellenarTabla),
      pw.SizedBox(height: 3),
      _valorEnLetras(c),
      pw.SizedBox(height: 7),
      _firmasYTotales(c),
      pw.SizedBox(height: 2),
      pw.Builder(
        builder: (ctx) => _pie(c, expedicion, pagina(ctx)),
      ),
    ];
  }

  static pw.Widget _encabezado(
    CotizacionImpresionEntity c,
    pw.ImageProvider? logo,
  ) {
    final lineasEmpresa = <String>[
      if (c.empresaNit != null && c.empresaNit!.isNotEmpty) 'NIT: ${c.empresaNit}',
      if (c.empresaDireccion != null && c.empresaDireccion!.isNotEmpty)
        c.empresaDireccion!,
      if (c.empresaTelefono != null && c.empresaTelefono!.isNotEmpty)
        'Tel: ${c.empresaTelefono}',
    ];

    return pw.SizedBox(
      width: _anchoInterior,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo
              pw.SizedBox(
                width: 105,
                height: 38,
                child: logo != null
                    ? pw.Image(logo,
                        fit: pw.BoxFit.contain, alignment: pw.Alignment.centerLeft)
                    : pw.SizedBox(),
              ),
              pw.SizedBox(width: 14),
              // Datos del negocio
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(c.empresaNombre, style: _s(11, bold: true)),
                    pw.SizedBox(height: 1),
                    ...lineasEmpresa.map(
                      (l) => pw.Text(l, style: _s(6.5, color: _grisTexto)),
                    ),
                  ],
                ),
              ),
              // Título y número
              pw.SizedBox(
                width: 194,
                child: pw.Column(
                  children: [
                    pw.Text('COTIZACIÓN', style: _s(9, bold: true, color: _azulTexto)),
                    pw.SizedBox(height: 4),
                    pw.Container(
                      width: 194,
                      height: 22,
                      alignment: pw.Alignment.center,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.black, width: 1.2),
                      ),
                      child: pw.Text(
                        'No. ${c.numeroCotizacion}',
                        style: _s(14, bold: true, color: _azulNumero),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Container(width: _anchoInterior, height: 1.2, color: PdfColors.black),
        ],
      ),
    );
  }

  static pw.Widget _clienteYFechas(CotizacionImpresionEntity c) {
    final fecha = c.fechaCotizacion.toLocal();

    return pw.SizedBox(
      width: _anchoInterior,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Cliente y observación
          pw.Column(
            children: [
              _cuadroCliente(c),
              pw.SizedBox(height: 3),
              _cuadroObservacion(c),
            ],
          ),
          pw.SizedBox(width: 6),
          // Fechas
          pw.Column(
            children: [
              _grupoFecha('FECHA', fecha),
              pw.SizedBox(height: 4),
              _grupoFecha('FECHA DE VALIDEZ', c.fechaValidez),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _cuadroCliente(CotizacionImpresionEntity c) {
    String valor(String? v) => (v == null || v.trim().isEmpty) ? _vacio : v;

    return pw.Container(
      width: 437,
      height: 36,
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _azulBorde, width: 0.8),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _etiquetaValor('CLIENTE:', valor(c.consumidorNombre)),
          pw.Row(
            children: [
              pw.SizedBox(
                width: 125,
                child: _etiquetaValor('NIT/C.C.:', valor(c.consumidorIdentificacion)),
              ),
              pw.SizedBox(
                width: 125,
                child: _etiquetaValor('TELÉFONOS:', valor(c.consumidorTelefono)),
              ),
              pw.Expanded(
                child: _etiquetaValor('CIUDAD:', valor(c.empresaCiudad)),
              ),
            ],
          ),
          _etiquetaValor('CORREO:', valor(c.consumidorEmail)),
        ],
      ),
    );
  }

  static pw.Widget _cuadroObservacion(CotizacionImpresionEntity c) {
    var obs = (c.observacion ?? '').trim();
    if (obs.isEmpty) obs = _vacio;
    if (obs.length > 170) obs = '${obs.substring(0, 167)}...';

    return pw.Container(
      width: 437,
      height: 36,
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      alignment: pw.Alignment.topLeft,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _azulBorde, width: 0.8),
      ),
      child: _etiquetaValor('OBSERVACIÓN:', obs),
    );
  }

  /// "ETIQUETA: valor" con la etiqueta en negrita azul
  static pw.Widget _etiquetaValor(String etiqueta, String valor) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$etiqueta ',
            style: _s(6.6, bold: true, color: _azulTexto),
          ),
          pw.TextSpan(text: valor, style: _s(6.6)),
        ],
      ),
    );
  }

  /// Grupo "FECHA" / "FECHA DE VALIDEZ" con las celdas DÍA | MES | AÑO
  static pw.Widget _grupoFecha(String titulo, DateTime? fecha) {
    String dos(int n) => n.toString().padLeft(2, '0');

    return pw.SizedBox(
      width: 67,
      child: pw.Column(
        children: [
          pw.Text(titulo, style: _s(5.2, bold: true, color: _azulTexto)),
          pw.SizedBox(height: 1.5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _cajaFecha('DÍA', fecha == null ? '-' : dos(fecha.day), 19),
              _cajaFecha('MES', fecha == null ? '-' : dos(fecha.month), 20),
              _cajaFecha('AÑO', fecha == null ? '-' : fecha.year.toString(), 24),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _cajaFecha(String titulo, String valor, double ancho) {
    return pw.Container(
      width: ancho,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.2),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            height: 11,
            width: ancho,
            color: _azulClaro,
            alignment: pw.Alignment.center,
            child: pw.Text(titulo, style: _s(4.8, bold: true, color: _azulTexto)),
          ),
          pw.Container(
            height: 15,
            width: ancho,
            alignment: pw.Alignment.center,
            child: pw.Text(
              valor,
              style: _s(titulo == 'AÑO' ? 8.6 : 9.3, bold: true),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _tabla(CotizacionImpresionEntity c, bool rellenar) {
    final lineas = c.lineas;

    // Alto restante para completar el área de la tabla (como en la web)
    final altoRelleno =
        _altoCuerpoTabla - 3 - (lineas.length * _altoFila);

    final borde = pw.BorderSide(color: PdfColors.black, width: _bordeMarco);

    return pw.Table(
      columnWidths: _columnas,
      border: pw.TableBorder(
        left: borde,
        right: borde,
        bottom: borde,
        verticalInside: pw.BorderSide(color: _grisLinea, width: 0.6),
      ),
      children: [
        // Encabezado (se repite en cada página)
        pw.TableRow(
          repeat: true,
          decoration: pw.BoxDecoration(color: _azulOscuro),
          children: [
            _celdaEncabezado('CANT.'),
            _celdaEncabezado('REF.'),
            _celdaEncabezado('DESCRIPCIÓN'),
            _celdaEncabezado('VR. UNI'),
            _celdaEncabezado('DCTO.'),
            _celdaEncabezado('% IVA'),
            _celdaEncabezado('TOTAL'),
          ],
        ),
        // Pequeño espacio superior del cuerpo
        pw.TableRow(
          children: List.generate(7, (_) => pw.SizedBox(height: 3)),
        ),
        // Líneas
        ...lineas.map(
          (l) => pw.TableRow(
            children: [
              _celdaCuerpo(_cantidad(l.cantidad), pw.TextAlign.center),
              _celdaCuerpo(l.referencia, pw.TextAlign.center),
              _celdaCuerpo(l.descripcion, pw.TextAlign.left),
              _celdaCuerpo(_numero(l.precioUnitario), pw.TextAlign.right),
              _celdaCuerpo(_numero(l.descuentoValor), pw.TextAlign.right),
              _celdaCuerpo(_numero(l.porcentajeImpuesto), pw.TextAlign.center),
              _celdaCuerpo(
                _numero(l.totalLinea),
                pw.TextAlign.right,
                bold: true,
              ),
            ],
          ),
        ),
        // Relleno hasta completar el alto mínimo
        if (rellenar && altoRelleno > 0)
          pw.TableRow(
            children: List.generate(7, (_) => pw.SizedBox(height: altoRelleno)),
          ),
        // Sin relleno (muchas líneas): pequeño espacio para no tocar el borde
        if (!rellenar || altoRelleno <= 0)
          pw.TableRow(
            children: List.generate(7, (_) => pw.SizedBox(height: 2.5)),
          ),
      ],
    );
  }

  static pw.Widget _celdaEncabezado(String texto) {
    return pw.Container(
      height: 15,
      alignment: pw.Alignment.center,
      child: pw.Text(
        texto,
        style: _s(6.5, bold: true, color: PdfColors.white),
      ),
    );
  }

  static pw.Widget _celdaCuerpo(
    String texto,
    pw.TextAlign alineacion, {
    bool bold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 2.5),
      child: pw.Text(
        texto,
        textAlign: alineacion,
        style: _s(5.4, bold: bold),
      ),
    );
  }

  static pw.Widget _valorEnLetras(CotizacionImpresionEntity c) {
    return pw.Container(
      width: _anchoInterior,
      height: 14,
      alignment: pw.Alignment.centerLeft,
      padding: const pw.EdgeInsets.symmetric(horizontal: 4),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _azulBorde, width: 0.8),
      ),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(text: 'Valor en letras:  ', style: _s(6.4, bold: true)),
            pw.TextSpan(
              text: numeroALetras(c.total),
              style: _s(6.4, color: _grisTexto),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _firmasYTotales(CotizacionImpresionEntity c) {
    return pw.SizedBox(
      width: _anchoInterior,
      height: 67,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: _bloqueFirma('VENDEDOR:', 'AUTORIZA'),
          ),
          pw.Expanded(
            child: _bloqueFirma('CLIENTE:', 'ACEPTADA'),
          ),
          _cuadroTotales(c),
        ],
      ),
    );
  }

  static pw.Widget _bloqueFirma(String titulo, String marca) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6),
      child: pw.Column(
        children: [
          pw.SizedBox(height: 5),
          pw.Text(titulo, style: _s(6.4, bold: true, color: _azulTexto)),
          pw.SizedBox(height: 8),
          pw.Text(marca, style: _s(12, bold: true, color: _grisMarca)),
          pw.Spacer(),
          pw.Container(height: 0.8, color: PdfColors.black),
          pw.SizedBox(height: 3),
          pw.Text('NIT/C.C.: ________________', style: _s(6)),
        ],
      ),
    );
  }

  static pw.Widget _cuadroTotales(CotizacionImpresionEntity c) {
    pw.Widget fila(String etiqueta, double valor) {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(etiqueta, style: _s(6.3, bold: true)),
          pw.Text(_numero(valor), style: _s(6.6)),
        ],
      );
    }

    return pw.Container(
      width: 112,
      height: 67,
      padding: const pw.EdgeInsets.fromLTRB(8, 7, 8, 6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: _bordeMarco),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          fila('SUBTOTAL', c.subtotal),
          fila('DCTO', c.totalDescuentos),
          fila('IVA', c.totalIva),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('TOTAL', style: _s(7.8, bold: true)),
              pw.Text(_numero(c.total), style: _s(8, bold: true)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _pie(
    CotizacionImpresionEntity c,
    DateTime expedicion,
    int pagina,
  ) {
    final emision = _fechaHora(c.fechaCotizacion.toLocal());
    final textoPie = pw.TextStyle(
      fontSize: 3.9,
      color: _grisTexto,
      lineSpacing: 0.9,
    );

    pw.Widget linea(String t) => pw.Text(t, style: textoPie);

    bool hay(String? v) => v != null && v.trim().isNotEmpty;

    return pw.SizedBox(
      width: _anchoInterior,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(height: 0.8, color: _grisLinea),
          pw.SizedBox(height: 3),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    linea(_textoLegal),
                    if (hay(c.facturaPiePagina)) linea(c.facturaPiePagina!),
                    if (hay(c.terminosCondiciones)) linea(c.terminosCondiciones!),
                    linea('Emisión: $emision'),
                    if (hay(c.notas)) linea(c.notas!),
                  ],
                ),
              ),
              pw.SizedBox(
                width: 150,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    if (hay(c.agradecimiento)) linea(c.agradecimiento!),
                    pw.SizedBox(height: 8),
                    linea('Expedición: ${_fechaHora(expedicion)}'),
                    linea('Documento: ${c.numeroCotizacion} pág. $pagina'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Utilidades
  // ---------------------------------------------------------------------------

  static pw.TextStyle _s(
    double size, {
    bool bold = false,
    PdfColor color = PdfColors.black,
  }) {
    return pw.TextStyle(
      fontSize: size,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: color,
    );
  }

  /// 34000 -> "34,000" (sin símbolo ni decimales, como en la web)
  static String _numero(double valor) {
    return NumberFormat('#,##0', 'en_US').format(valor);
  }

  /// 1.0 -> "1", 1.5 -> "1.5"
  static String _cantidad(double valor) {
    return valor == valor.truncateToDouble()
        ? valor.toInt().toString()
        : valor.toString();
  }

  /// 2026-11-25 10:31:28
  static String _fechaHora(DateTime fecha) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(fecha);
  }
}
