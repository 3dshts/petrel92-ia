// frontend/lib/src/features/fabricacion/widgets/fabricacion_table.dart

import 'package:flutter/material.dart';
import '../../../core/models/fabricacion_model.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

// ============================================
// CONSTANTES
// ============================================

/// Breakpoint para determinar vista móvil.
class _TableBreakpoints {
  static const double mobile = 768.0;
}

/// Dimensiones de la tabla.
class _TableDimensions {
  static const double desktopColumnSpacing = 16.0;
  static const double mobileColumnSpacing = 8.0;
  static const double desktopHorizontalMargin = 24.0;
  static const double mobileHorizontalMargin = 12.0;
  static const double desktopHeadingRowHeight = 56.0;
  static const double mobileHeadingRowHeight = 48.0;
  static const double desktopDataRowHeight = 56.0;
  static const double mobileDataRowHeight = 48.0;
  static const double iconSize = 16.0;
}

/// Anchos fijos de columnas para móvil.
class _MobileColumnWidths {
  static const double agrupacion = 80.0;
  static const double nota = 100.0;
  static const double partida = 60.0;
  static const double fservicio = 110.0;
  static const double pedido = 100.0;
  static const double modelo = 150.0;
  static const double combinacion = 100.0;
  static const double titulo = 250.0;
  static const double pares = 120.0;
  static const double snoseccion = 80.0;
  static const double secdescri = 150.0;
  static const double snoufecha = 110.0;
}

/// Proporciones de columnas para desktop (suman 100).
class _DesktopColumnFlex {
  static const int agrupacion = 6;
  static const int nota = 8;
  static const int partida = 5;
  static const int fservicio = 8;
  static const int pedido = 8;
  static const int modelo = 12;
  static const int combinacion = 7;
  static const int titulo = 16;
  static const int pares = 10;
  static const int snoseccion = 7;
  static const int secdescri = 10;
  static const int snoufecha = 8;
}

/// Tamaños de fuente.
class _FontSizes {
  static const double desktopText = 14.0;
  static const double mobileText = 12.0;
  static const double mobileHint = 10.0;
}

/// Textos de la interfaz.
class _UITexts {
  static const String swipeHintMobile = 'Desliza horizontalmente para ver más';
  static const String emptyState = 'No hay resultados para mostrar';
  
  // Nombres de columnas
  static const String agrupColumn = 'Agrup';
  static const String notaColumn = 'Nota';
  static const String partidaColumn = 'Sub';
  static const String fservicioColumn = 'F. Servicio';
  static const String pedidoColumn = 'Ped. Cliente';
  static const String modeloColumn = 'Modelo';
  static const String combinacionColumn = 'Comb';
  static const String tituloColumn = 'Título';
  static const String paresColumn = 'Total Pares';
  static const String snoseccionColumn = 'Sección';
  static const String secdescriColumn = 'Descripción';
  static const String snoufechaColumn = 'F. Sección';
  
  static String resultCount(int count) => '$count registro(s)';
}

/// Configuración de bordes.
class _BorderConfig {
  static const double radius = 8.0;
}

// ============================================
// WIDGET PRINCIPAL
// ============================================

/// Tabla especializada para mostrar datos de fabricación.
/// 
/// En móvil: Scroll horizontal con anchos fijos.
/// En desktop: Columnas expansibles que ocupan todo el ancho.
class FabricacionTable extends StatelessWidget {
  const FabricacionTable({
    super.key,
    required this.registros,
  });

  final List<FabricacionModel> registros;

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.of(context).size.width < _TableBreakpoints.mobile;

    if (registros.isEmpty) {
      return _buildEmptyState(isMobile);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile) ...[
          _buildSwipeHint(),
          const SizedBox(height: AppSpacing.small),
        ],
        _buildTable(context, isMobile),
        SizedBox(height: isMobile ? AppSpacing.small : AppSpacing.medium),
        _buildResultCount(isMobile),
      ],
    );
  }

  // ============================================
  // ESTADO VACÍO
  // ============================================

  Widget _buildEmptyState(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? AppSpacing.xl : 40.0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(_BorderConfig.radius),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: isMobile ? 48.0 : 64.0,
              color: AppColors.text.withOpacity(0.3),
            ),
            SizedBox(height: isMobile ? AppSpacing.medium : AppSpacing.large),
            Text(
              _UITexts.emptyState,
              style: TextStyle(
                fontSize: isMobile ? _FontSizes.mobileText : _FontSizes.desktopText,
                color: AppColors.text.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // HINT DE SCROLL (SOLO MÓVIL)
  // ============================================

  Widget _buildSwipeHint() {
    return Row(
      children: [
        Icon(
          Icons.swipe,
          size: _TableDimensions.iconSize,
          color: AppColors.text.withOpacity(0.6),
        ),
        const SizedBox(width: 4.0),
        Text(
          _UITexts.swipeHintMobile,
          style: TextStyle(
            fontSize: _FontSizes.mobileHint,
            color: AppColors.text.withOpacity(0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  // ============================================
  // TABLA
  // ============================================

  Widget _buildTable(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(_BorderConfig.radius),
      ),
      child: isMobile
          ? _buildMobileScrollableTable(context)
          : _buildDesktopTable(),
    );
  }

  // ============================================
  // TABLA MÓVIL (CON SCROLL)
  // ============================================

  Widget _buildMobileScrollableTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: _buildDataTable(true),
    );
  }

  // ============================================
  // TABLA DESKTOP (SIN SCROLL, EXPANSIBLE)
  // ============================================

  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      child: _buildResponsiveTable(),
    );
  }

  Widget _buildResponsiveTable() {
    return Table(
      columnWidths: {
        0: FlexColumnWidth(_DesktopColumnFlex.agrupacion.toDouble()),
        1: FlexColumnWidth(_DesktopColumnFlex.nota.toDouble()),
        2: FlexColumnWidth(_DesktopColumnFlex.partida.toDouble()),
        3: FlexColumnWidth(_DesktopColumnFlex.fservicio.toDouble()),
        4: FlexColumnWidth(_DesktopColumnFlex.pedido.toDouble()),
        5: FlexColumnWidth(_DesktopColumnFlex.modelo.toDouble()),
        6: FlexColumnWidth(_DesktopColumnFlex.combinacion.toDouble()),
        7: FlexColumnWidth(_DesktopColumnFlex.titulo.toDouble()),
        8: FlexColumnWidth(_DesktopColumnFlex.snoseccion.toDouble()),
        9: FlexColumnWidth(_DesktopColumnFlex.secdescri.toDouble()),
        10: FlexColumnWidth(_DesktopColumnFlex.snoufecha.toDouble()),
        11: FlexColumnWidth(_DesktopColumnFlex.pares.toDouble()),
      },
      border: TableBorder(
        horizontalInside: BorderSide(
          color: AppColors.cardBorder,
          width: 1.0,
        ),
      ),
      children: [
        _buildDesktopHeaderRow(),
        ...registros.map(_buildDesktopDataRow),
      ],
    );
  }

  TableRow _buildDesktopHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(
        color: AppColors.cardBorder.withOpacity(0.3),
      ),
      children: [
        _buildDesktopHeaderCell(_UITexts.agrupColumn),
        _buildDesktopHeaderCell(_UITexts.notaColumn),
        _buildDesktopHeaderCell(_UITexts.partidaColumn),
        _buildDesktopHeaderCell(_UITexts.fservicioColumn),
        _buildDesktopHeaderCell(_UITexts.pedidoColumn),
        _buildDesktopHeaderCell(_UITexts.modeloColumn),
        _buildDesktopHeaderCell(_UITexts.combinacionColumn),
        _buildDesktopHeaderCell(_UITexts.tituloColumn),
        _buildDesktopHeaderCell(_UITexts.snoseccionColumn),
        _buildDesktopHeaderCell(_UITexts.secdescriColumn),
        _buildDesktopHeaderCell(_UITexts.snoufechaColumn),
        _buildDesktopHeaderCell(_UITexts.paresColumn),
      ],
    );
  }

  Widget _buildDesktopHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: AppFontWeights.semiBold,
          fontSize: _FontSizes.desktopText,
          color: AppColors.primary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  TableRow _buildDesktopDataRow(FabricacionModel registro) {
    return TableRow(
      children: [
        _buildDesktopDataCell(registro.agrupacion),
        _buildDesktopDataCell(registro.nota),
        _buildDesktopDataCell(registro.partida),
        _buildDesktopDataCell(_formatDate(registro.fservicio)),
        _buildDesktopDataCell(registro.pedido),
        _buildDesktopDataCell(registro.modelo),
        _buildDesktopDataCell(registro.combinacion),
        _buildDesktopDataCell(registro.titulo),
        _buildDesktopDataCell(registro.snoseccion),
        _buildDesktopDataCell(registro.secdescri),
        _buildDesktopDataCell(_formatDate(registro.snoufecha)),
        _buildDesktopDataCell(registro.pares),
      ],
    );
  }

  Widget _buildDesktopDataCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: _FontSizes.desktopText,
          color: AppColors.text,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }

  // ============================================
  // DATA TABLE (SOLO PARA MÓVIL)
  // ============================================

  Widget _buildDataTable(bool isMobile) {
    return DataTable(
      columnSpacing: _TableDimensions.mobileColumnSpacing,
      horizontalMargin: _TableDimensions.mobileHorizontalMargin,
      headingRowHeight: _TableDimensions.mobileHeadingRowHeight,
      dataRowHeight: _TableDimensions.mobileDataRowHeight,
      headingTextStyle: TextStyle(
        fontWeight: AppFontWeights.semiBold,
        fontSize: _FontSizes.mobileText,
        color: AppColors.primary,
      ),
      dataTextStyle: TextStyle(
        fontSize: _FontSizes.mobileText,
        color: AppColors.text,
      ),
      columns: _buildColumns(),
      rows: registros.map(_buildMobileRow).toList(),
    );
  }

  // ============================================
  // COLUMNAS (MÓVIL)
  // ============================================

  List<DataColumn> _buildColumns() {
    return const [
      DataColumn(
        label: Text(_UITexts.agrupColumn, overflow: TextOverflow.ellipsis),
      ),
      DataColumn(
        label: Text(_UITexts.notaColumn, overflow: TextOverflow.ellipsis),
      ),
      DataColumn(
        label: Text(_UITexts.partidaColumn, overflow: TextOverflow.ellipsis),
      ),
      DataColumn(
        label: Text(_UITexts.fservicioColumn, overflow: TextOverflow.ellipsis),
      ),
      DataColumn(
        label: Text(_UITexts.pedidoColumn, overflow: TextOverflow.ellipsis),
      ),
      DataColumn(
        label: Text(_UITexts.modeloColumn, overflow: TextOverflow.ellipsis),
      ),
      DataColumn(
        label: Text(_UITexts.combinacionColumn, overflow: TextOverflow.ellipsis),
      ),
      DataColumn(
        label: Text(_UITexts.tituloColumn, overflow: TextOverflow.ellipsis),
      ),
      DataColumn(
        label: Text(_UITexts.snoseccionColumn, overflow: TextOverflow.ellipsis),
      ),
      DataColumn(
        label: Text(_UITexts.secdescriColumn, overflow: TextOverflow.ellipsis),
      ),
      DataColumn(
        label: Text(_UITexts.snoufechaColumn, overflow: TextOverflow.ellipsis),
      ),
      DataColumn(
        label: Text(_UITexts.paresColumn, overflow: TextOverflow.ellipsis),
      ),
    ];
  }

  // ============================================
  // FILA DE DATOS (MÓVIL)
  // ============================================

  DataRow _buildMobileRow(FabricacionModel registro) {
    return DataRow(
      cells: [
        DataCell(_buildMobileCell(registro.agrupacion, _MobileColumnWidths.agrupacion)),
        DataCell(_buildMobileCell(registro.nota, _MobileColumnWidths.nota)),
        DataCell(_buildMobileCell(registro.partida, _MobileColumnWidths.partida)),
        DataCell(_buildMobileCell(_formatDate(registro.fservicio), _MobileColumnWidths.fservicio)),
        DataCell(_buildMobileCell(registro.pedido, _MobileColumnWidths.pedido)),
        DataCell(_buildMobileCell(registro.modelo, _MobileColumnWidths.modelo)),
        DataCell(_buildMobileCell(registro.combinacion, _MobileColumnWidths.combinacion)),
        DataCell(_buildMobileCell(registro.titulo, _MobileColumnWidths.titulo)),
        DataCell(_buildMobileCell(registro.snoseccion, _MobileColumnWidths.snoseccion)),
        DataCell(_buildMobileCell(registro.secdescri, _MobileColumnWidths.secdescri)),
        DataCell(_buildMobileCell(_formatDate(registro.snoufecha), _MobileColumnWidths.snoufecha)),
        DataCell(_buildMobileCell(registro.pares, _MobileColumnWidths.pares)),
      ],
    );
  }

  // ============================================
  // CELDA CON ANCHO MÁXIMO (MÓVIL)
  // ============================================

  Widget _buildMobileCell(String text, double maxWidth) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  // ============================================
  // CONTADOR DE RESULTADOS
  // ============================================

  Widget _buildResultCount(bool isMobile) {
    return Row(
      children: [
        Text(
          _UITexts.resultCount(registros.length),
          style: TextStyle(
            fontSize: isMobile ? _FontSizes.mobileText : _FontSizes.desktopText,
            fontWeight: AppFontWeights.semiBold,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  // ============================================
  // UTILIDADES
  // ============================================

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}