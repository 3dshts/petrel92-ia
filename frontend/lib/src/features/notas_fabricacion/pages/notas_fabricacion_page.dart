// frontend/lib/src/features/fabricacion/pages/notas_fabricacion_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/common_widgets/custom_app_bar.dart';
import '../../../core/common_widgets/common_text_field.dart';
import '../../../core/common_widgets/common_date_picker.dart';
import '../../../core/common_widgets/primary_button.dart';
import '../../../core/common_widgets/floating_back_button.dart';
import '../../../core/common_widgets/decorative_corner_icon.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/models/fabricacion_model.dart';
import '../../../core/calendar/calendar_cubit.dart';
import '../../../core/user/user_cubit.dart';
import '../../../core/user/user_state.dart';
import '../widgets/fabricacion_table.dart';
import '../widgets/calendar_fab.dart';
import '../widgets/calendar_drawer.dart';
import '../widgets/calendar_bottom_sheet.dart';

// ============================================
// CONSTANTES
// ============================================

/// Claves de campos del formulario.
class _FormFields {
  static const String fechaDesde = 'fechaDesde';
  static const String fechaHasta = 'fechaHasta';
  static const String seccion = 'seccion';
  static const String temporada = 'temporada';
}

/// Labels legibles de los campos.
class _FieldLabels {
  static const Map<String, String> map = {
    _FormFields.fechaDesde: 'Fecha Desde',
    _FormFields.fechaHasta: 'Fecha Hasta',
    _FormFields.seccion: 'Sección',
    _FormFields.temporada: 'Temporada',
  };
}

/// Mensajes de validación.
class _ValidationMessages {
  static const String fechaDesdeRequired = 'Selecciona una fecha de inicio.';
  static const String fechaHastaRequired = 'Selecciona una fecha de fin.';
  static const String seccionRequired = 'La sección es obligatoria.';
  static const String temporadaRequired = 'La temporada es obligatoria.';
  static const String fechaRangoInvalido =
      'La fecha de inicio no puede ser posterior a la fecha de fin.';

  static String buildAggregateError(List<String> missingFields) {
    return 'Faltan los campos: ${missingFields.join(', ')}.';
  }
}

/// Mensajes de estado.
class _StatusMessages {
  static const String querying = 'Consultando...';
  static const String queryError = 'Error al consultar la API';
  static const String noResults = 'No se encontraron resultados';
  static const String ready = 'Listo';

  static String resultsFound(int count) => 'Se encontraron $count registros';
}

/// Textos de la interfaz.
class _UITexts {
  static const String title = 'NOTAS FABRICACIÓN';
  static const String fechaDesdeLabel = 'Fecha Desde';
  static const String fechaHastaLabel = 'Fecha Hasta';
  static const String seccionLabel = 'Sección';
  static const String temporadaLabel = 'Temporada';
  static const String consultButton = 'Consultar';
  static const String consultButtonLoading = 'Consultando...';
  static const String emptyTableHint =
      'Realiza una consulta para ver los resultados';
  static String totalPares(int count) => 'Total Pares: $count';

  static String pageInfo(int current, int total) => 'Página $current de $total';
  static String totalResults(int count) => 'Total: $count registros';
}

/// Dimensiones responsive.
class _ResponsiveDimensions {
  static const double maxFormWidth = 1200.0;
  static const double mobileWatermarkSizeFactor = 0.4;
  static const double desktopWatermarkSizeFactor = 0.5;
  static const double mobileWatermarkSizePx = 240.0;
  static const double desktopWatermarkSizePx = 360.0;
  static const double mobilePaddingVertical = 24.0;
  static const double desktopPaddingVertical = 40.0;
}

/// Tamaños de fuente personalizados.
class _CustomFontSizes {
  static const double statusText = 13.0;
  static const double pageInfoText = 14.0;
}

/// Formato de fechas para la API.
class _DateFormat {
  static String format(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// ============================================
// PÁGINA PRINCIPAL CON PROVIDER
// ============================================

class NotasFabricacionPage extends StatelessWidget {
  const NotasFabricacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Envolver con CalendarProvider para dar acceso al CalendarCubit
    return BlocProvider(
      create: (_) => CalendarCubit(),
      child: const _NotasFabricacionPageContent(),
    );
  }
}

// ============================================
// CONTENIDO DE LA PÁGINA
// ============================================

class _NotasFabricacionPageContent extends StatefulWidget {
  const _NotasFabricacionPageContent();

  @override
  State<_NotasFabricacionPageContent> createState() =>
      _NotasFabricacionPageContentState();
}

class _NotasFabricacionPageContentState
    extends State<_NotasFabricacionPageContent> {
  // Estado del calendario
  bool _isCalendarOpen = false;

  /// Alterna la visibilidad del calendario.
  void _toggleCalendar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop =
        screenWidth >= AppBreakpoints.desktop; // ← Solo desktop usa drawer

    if (isDesktop) {
      // Desktop: Toggle drawer
      setState(() => _isCalendarOpen = !_isCalendarOpen);
    } else {
      // Móvil y Tablet: Abrir BottomSheet
      _openCalendarBottomSheet();
    }
  }

  /// Cierra el drawer del calendario (solo desktop/tablet).
  void _closeCalendarDrawer() {
    setState(() => _isCalendarOpen = false);
  }

  /// Abre el BottomSheet del calendario (solo móvil).
  void _openCalendarBottomSheet() {
    final userState = context.read<UserCubit>().state;
    String autorNombre = 'Usuario';
    String autorId = 'unknown';

    if (userState is UserLoaded) {
      autorNombre = userState.fullName;
      autorId = userState.username;
    }

    // Obtener el CalendarCubit actual ANTES de abrir el bottom sheet
    final calendarCubit = context.read<CalendarCubit>();

    showCalendarBottomSheet(
      context: context,
      calendarCubit: calendarCubit, // ← NUEVO: Pasar el cubit
      autorNombre: autorNombre,
      autorId: autorId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppBreakpoints.mobile;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: ViewportWatermarkWidget(
        asset: 'assets/dashboard_icons/fabricacion.svg',
        sizeFactor: isMobile
            ? _ResponsiveDimensions.mobileWatermarkSizeFactor
            : _ResponsiveDimensions.desktopWatermarkSizeFactor,
        sizePx: isMobile
            ? _ResponsiveDimensions.mobileWatermarkSizePx
            : _ResponsiveDimensions.desktopWatermarkSizePx,
        child: Stack(
          children: [
            // Contenido principal
            Row(
              children: [
                // Contenido del formulario
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? AppSpacing.large : AppSpacing.xxl,
                      vertical: isMobile
                          ? _ResponsiveDimensions.mobilePaddingVertical
                          : _ResponsiveDimensions.desktopPaddingVertical,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _ResponsiveDimensions.maxFormWidth + 200,
                        ),
                        child: const _FabricacionForm(),
                      ),
                    ),
                  ),
                ),

                // Drawer del calendario (solo desktop)
                if (_isCalendarOpen && screenWidth >= AppBreakpoints.desktop)
                  BlocBuilder<UserCubit, UserState>(
                    builder: (context, userState) {
                      String autorNombre = 'Usuario';
                      String autorId = 'unknown';

                      if (userState is UserLoaded) {
                        autorNombre = userState.fullName;
                        autorId = userState.username;
                      }

                      return CalendarDrawer(
                        onClose: _closeCalendarDrawer,
                        autorNombre: autorNombre,
                        autorId: autorId,
                      );
                    },
                  ),
              ],
            ),

            // Botón de volver
            const FloatingBackButton(),

            // FAB del calendario
            Positioned(
              right: AppSpacing.large,
              bottom: AppSpacing.large,
              child: CalendarFAB(onPressed: _toggleCalendar),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// FORMULARIO DE FABRICACIÓN
// ============================================

class _FabricacionForm extends StatefulWidget {
  const _FabricacionForm();

  @override
  State<_FabricacionForm> createState() => _FabricacionFormState();
}

class _FabricacionFormState extends State<_FabricacionForm> {
  // Controladores
  final _seccionController = TextEditingController();
  final _temporadaController = TextEditingController();

  // Estado del formulario
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  // Estado de la consulta
  bool _isQuerying = false;
  String _statusMsg = '';

  // Todos los resultados obtenidos del backend
  List<FabricacionModel> _allResultados = [];

  // Paginación local
  int _currentPage = 1;
  int _totalPages = 0;
  int _totalCount = 0;
  final int _itemsPerPage = 10;

  bool _hasQueried = false;

  // Errores de validación por campo
  Map<String, String?> _fieldErrors = {};

  @override
  void dispose() {
    _seccionController.dispose();
    _temporadaController.dispose();
    super.dispose();
  }

  // ============================================
  // VALIDACIÓN
  // ============================================

  bool _validateFields() {
    final errors = <String, String?>{};

    if (_fechaDesde == null) {
      errors[_FormFields.fechaDesde] = _ValidationMessages.fechaDesdeRequired;
    }

    if (_fechaHasta == null) {
      errors[_FormFields.fechaHasta] = _ValidationMessages.fechaHastaRequired;
    }

    if (_fechaDesde != null &&
        _fechaHasta != null &&
        _fechaDesde!.isAfter(_fechaHasta!)) {
      errors[_FormFields.fechaDesde] = _ValidationMessages.fechaRangoInvalido;
    }

    if (_seccionController.text.trim().isEmpty) {
      errors[_FormFields.seccion] = _ValidationMessages.seccionRequired;
    }

    if (_temporadaController.text.trim().isEmpty) {
      errors[_FormFields.temporada] = _ValidationMessages.temporadaRequired;
    }

    setState(() => _fieldErrors = errors);
    return errors.isEmpty;
  }

  String _buildValidationErrorMessage() {
    if (_fieldErrors.isEmpty) return '';

    final missingFields = _fieldErrors.keys
        .map((key) => _FieldLabels.map[key] ?? key)
        .toList();

    return _ValidationMessages.buildAggregateError(missingFields);
  }

  // ============================================
  // CONSULTA A LA API
  // ============================================

  Future<void> _queryApi() async {
    // Validar campos
    if (!_validateFields()) {
      setState(() {
        _statusMsg = _buildValidationErrorMessage();
        _hasQueried = false;
      });
      return;
    }

    setState(() {
      _isQuerying = true;
      _statusMsg = _StatusMessages.querying;
      _allResultados = [];
      _currentPage = 1;
      _totalPages = 0;
      _totalCount = 0;
    });

    try {
      // Realizar la consulta usando DioClient
      final response = await DioClient.getNotasProduccion(
        fechaDesde: _DateFormat.format(_fechaDesde!),
        fechaHasta: _DateFormat.format(_fechaHasta!),
        seccion: _seccionController.text.trim(),
        temporada: _temporadaController.text.trim(),
      );

      // Procesar la respuesta
      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> records = data['data'];

          // Convertir a modelos
          final resultados = records
              .map((json) => FabricacionModel.fromJson(json))
              .toList();

          // Calcular paginación local
          final totalCount = resultados.length;
          final totalPages = (totalCount / _itemsPerPage).ceil();

          setState(() {
            _allResultados = resultados;
            _totalCount = totalCount;
            _totalPages = totalPages > 0 ? totalPages : 1;
            _currentPage = 1;
            _statusMsg = _StatusMessages.resultsFound(totalCount);
            _hasQueried = true;
          });
        } else {
          setState(() {
            _statusMsg = data['message'] ?? _StatusMessages.noResults;
            _hasQueried = true;
          });
        }
      } else {
        setState(() {
          _statusMsg = '${_StatusMessages.queryError}: ${response.statusCode}';
          _hasQueried = true;
        });
      }
    } catch (e) {
      setState(() {
        _statusMsg = '${_StatusMessages.queryError}: ${e.toString()}';
        _hasQueried = true;
      });
    } finally {
      setState(() => _isQuerying = false);
    }
  }

  // ============================================
  // PAGINACIÓN LOCAL
  // ============================================

  List<FabricacionModel> _getCurrentPageData() {
    if (_allResultados.isEmpty) return [];

    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(
      0,
      _allResultados.length,
    );

    return _allResultados.sublist(startIndex, endIndex);
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      setState(() => _currentPage++);
    }
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      setState(() => _currentPage = page);
    }
  }

  // ============================================
  // UI
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTitle(context),
        const SizedBox(height: AppSpacing.large),
        _buildFormFields(),
        const SizedBox(height: AppSpacing.large),
        if (_statusMsg.isNotEmpty) _buildStatusMessage(),
        _buildConsultButton(),
        const SizedBox(height: AppSpacing.xxl),
        _buildDivider(),
        const SizedBox(height: AppSpacing.xxl),
        _buildResultsSection(),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Center(
      child: Text(
        _UITexts.title,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: AppFontWeights.bold),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildFechaDesdeField()),
            const SizedBox(width: AppSpacing.medium),
            Expanded(child: _buildFechaHastaField()),
          ],
        ),
        const SizedBox(height: AppSpacing.medium),
        Row(
          children: [
            Expanded(child: _buildSeccionField()),
            const SizedBox(width: AppSpacing.medium),
            Expanded(child: _buildTemporadaField()),
          ],
        ),
      ],
    );
  }

  Widget _buildFechaDesdeField() {
    return CommonDatePicker(
      label: _UITexts.fechaDesdeLabel,
      selectedDate: _fechaDesde,
      onDateSelected: (date) => setState(() => _fechaDesde = date),
      errorText: _fieldErrors[_FormFields.fechaDesde],
    );
  }

  Widget _buildFechaHastaField() {
    return CommonDatePicker(
      label: _UITexts.fechaHastaLabel,
      selectedDate: _fechaHasta,
      onDateSelected: (date) => setState(() => _fechaHasta = date),
      errorText: _fieldErrors[_FormFields.fechaHasta],
    );
  }

  Widget _buildSeccionField() {
    return CommonTextField(
      controller: _seccionController,
      label: _UITexts.seccionLabel,
      hintText: 'Ej: 5',
      errorText: _fieldErrors[_FormFields.seccion],
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildTemporadaField() {
    return CommonTextField(
      controller: _temporadaController,
      label: _UITexts.temporadaLabel,
      hintText: 'Ej: 126',
      errorText: _fieldErrors[_FormFields.temporada],
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: AppColors.accent,
      thickness: AppBorderWidth.normal,
    );
  }

  Widget _buildStatusMessage() {
    final isError =
        _statusMsg.toLowerCase().contains('error') ||
        _statusMsg.toLowerCase().contains('faltan');

    return Column(
      children: [
        Text(
          _statusMsg,
          style: TextStyle(
            fontSize: _CustomFontSizes.statusText,
            color: isError ? AppColors.error : AppColors.text,
            fontWeight: AppFontWeights.medium,
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
      ],
    );
  }

  Widget _buildConsultButton() {
    return PrimaryButton(
      text: _isQuerying
          ? _UITexts.consultButtonLoading
          : _UITexts.consultButton,
      onPressed: () => _queryApi(),
      isLoading: _isQuerying,
    );
  }

  Widget _buildResultsSection() {
    if (!_hasQueried) {
      return _buildEmptyState();
    }

    if (_allResultados.isEmpty) {
      return _buildNoResultsState();
    }

    return Column(
      children: [
        _buildTableInfo(),
        const SizedBox(height: AppSpacing.medium),
        _buildTable(),
        const SizedBox(height: AppSpacing.large),
        _buildPagination(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search,
              size: 64.0,
              color: AppColors.text.withOpacity(0.3),
            ),
            const SizedBox(height: AppSpacing.large),
            Text(
              _UITexts.emptyTableHint,
              style: TextStyle(
                fontSize: AppFontSizes.medium,
                color: AppColors.text.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox,
              size: 64.0,
              color: AppColors.text.withOpacity(0.3),
            ),
            const SizedBox(height: AppSpacing.large),
            Text(
              _StatusMessages.noResults,
              style: TextStyle(
                fontSize: AppFontSizes.medium,
                color: AppColors.text.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableInfo() {
    final totalPares = _allResultados.fold<int>(
      0,
      (sum, registro) => sum + (int.tryParse(registro.pares) ?? 0),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _UITexts.totalResults(_totalCount),
          style: TextStyle(
            fontSize: _CustomFontSizes.pageInfoText,
            fontWeight: AppFontWeights.semiBold,
            color: AppColors.primary,
          ),
        ),
        Text(
          _UITexts.totalPares(totalPares),
          style: TextStyle(
            fontSize: _CustomFontSizes.pageInfoText,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildTable() {
    // Mostrar solo los datos de la página actual
    return FabricacionTable(registros: _getCurrentPageData());
  }

  Widget _buildPagination() {
    if (_totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _currentPage > 1 ? _previousPage : null,
          color: _currentPage > 1 ? AppColors.primary : AppColors.border,
        ),
        const SizedBox(width: AppSpacing.small),
        ..._buildPageNumbers(),
        const SizedBox(width: AppSpacing.small),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _currentPage < _totalPages ? _nextPage : null,
          color: _currentPage < _totalPages
              ? AppColors.primary
              : AppColors.border,
        ),
      ],
    );
  }

  List<Widget> _buildPageNumbers() {
    final List<Widget> pageNumbers = [];
    const maxVisiblePages = 5;

    int startPage = (_currentPage - (maxVisiblePages ~/ 2)).clamp(
      1,
      _totalPages,
    );
    int endPage = (startPage + maxVisiblePages - 1).clamp(1, _totalPages);

    // Ajustar startPage si endPage está al límite
    if (endPage == _totalPages) {
      startPage = (endPage - maxVisiblePages + 1).clamp(1, _totalPages);
    }

    // Botón primera página si no está visible
    if (startPage > 1) {
      pageNumbers.add(_buildPageButton(1));
      if (startPage > 2) {
        pageNumbers.add(_buildEllipsis());
      }
    }

    // Páginas visibles
    for (int i = startPage; i <= endPage; i++) {
      pageNumbers.add(_buildPageButton(i));
    }

    // Botón última página si no está visible
    if (endPage < _totalPages) {
      if (endPage < _totalPages - 1) {
        pageNumbers.add(_buildEllipsis());
      }
      pageNumbers.add(_buildPageButton(_totalPages));
    }

    return pageNumbers;
  }

  Widget _buildPageButton(int page) {
    final isCurrentPage = page == _currentPage;

    return InkWell(
      onTap: isCurrentPage ? null : () => _goToPage(page),
      borderRadius: BorderRadius.circular(AppBorderRadius.small),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.small,
        ),
        decoration: BoxDecoration(
          color: isCurrentPage ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
          border: Border.all(
            color: isCurrentPage ? AppColors.primary : AppColors.border,
            width: 1.0,
          ),
        ),
        child: Text(
          '$page',
          style: TextStyle(
            color: isCurrentPage ? AppColors.lightText : AppColors.text,
            fontWeight: isCurrentPage
                ? AppFontWeights.bold
                : AppFontWeights.regular,
            fontSize: AppFontSizes.small,
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Text(
        '...',
        style: TextStyle(color: AppColors.text, fontSize: AppFontSizes.small),
      ),
    );
  }
}
