// frontend/lib/src/features/situacion_pedidos/pages/situacion_pedidos_page.dart

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/common_widgets/custom_app_bar.dart';
import '../../../core/common_widgets/custom_dropdown.dart';
import '../../../core/common_widgets/decorative_corner_icon.dart';
import '../../../core/common_widgets/single_file_picker.dart';
import '../../../core/common_widgets/multi_file_group_picker.dart';
import '../../../core/common_widgets/primary_button.dart';
import '../../../core/common_widgets/floating_back_button.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/json_sender.dart';
import '../../../core/network/dio_client.dart';

// ============================================
// CONSTANTES
// ============================================

/// Endpoints externos de la aplicación.
class _SituacionPedidosEndpoints {
  static const String makeWebhookVersace =
      'https://hook.eu2.make.com/b8swle5qmcebo5w4qabefir37hu196j1';
  static const String makeWebhookSW =
      'https://hook.eu2.make.com/967vicdrp1fueprt9y1xniw1fpt4iith';
}
/// Marcas disponibles en el sistema.
class _BrandsList {
  static const String stuartWeitzman = 'STUART WEITZMAN';
  static const String versace = 'VERSACE';

  static const List<String> all = [stuartWeitzman, versace];
}

/// Opciones de Colección para Stuart Weitzman.
class _CollectionOptions {
  static const String mainCollection = 'MAIN COLLECTION';
  static const String outlet = 'OUTLET';
  static const String capsule = 'CAPSULE';

  static const List<String> all = [mainCollection, outlet, capsule];
}

/// Extensiones permitidas para archivos.
class _FileExtensions {
  static const List<String> pdf = ['pdf'];
  static const List<String> excel = ['xls', 'xlsx', 'xlsm'];
}

/// Assets de iconos.
class _IconAssets {
  static const String pdf = 'assets/component_icons/pdf_icon.svg';
  static const String excel = 'assets/component_icons/excel_icon.svg';
  static const String watermark =
      'assets/dashboard_icons/situacion_pedidos.svg';
}

/// Claves de campos del formulario.
class _FormFields {
  static const String marca = 'marca';
  // Versace
  static const String informeFechas = 'informeFechas';
  static const String dirma = 'dirma';
  static const String informePasado = 'informePasado';
  static const String informeNuevo = 'informeNuevo';
  // Stuart Weitzman
  static const String year = 'year';
  static const String month = 'month';
  static const String coleccion = 'coleccion';
  static const String erpSusy = 'erpSusy';
  static const String planningCliente = 'planningCliente';
}

/// Labels legibles de los campos.
class _FieldLabels {
  static const Map<String, String> map = {
    _FormFields.marca: 'Marca',
    // Versace
    _FormFields.informeFechas: 'Informe Fechas',
    _FormFields.dirma: 'DIRMA',
    _FormFields.informePasado: 'Informe Pasado',
    _FormFields.informeNuevo: 'Informe Nuevo',
    // Stuart Weitzman
    _FormFields.year: 'Año',
    _FormFields.month: 'Mes',
    _FormFields.coleccion: 'Colección',
    _FormFields.erpSusy: 'ERP SUSY',
    _FormFields.planningCliente: 'Planning Cliente',
  };
}

/// Mensajes de validación.
class _ValidationMessages {
  static const String marcaRequired = 'Selecciona una marca.';
  // Versace
  static const String informeFechasRequired =
      'Selecciona el archivo Informe Fechas (PDF).';
  static const String dirmaRequired = 'Selecciona el archivo DIRMA (Excel).';
  static const String informePasadoRequired =
      'Selecciona el archivo Informe Pasado (Excel).';
  static const String informeNuevoRequired =
      'Selecciona el archivo Informe Nuevo (Excel).';
  // Stuart Weitzman
  static const String yearRequired = 'Selecciona un año.';
  static const String monthRequired = 'Selecciona un mes.';
  static const String coleccionRequired = 'Selecciona una colección.';
  static const String erpSusyRequired =
      'Debes seleccionar al menos un archivo ERP SUSY (PDF).';
  static const String planningClienteRequired =
      'Selecciona el archivo Planning Cliente (Excel).';

  static String buildAggregateError(List<String> missingFields) {
    return 'Faltan los campos: ${missingFields.join(', ')}.';
  }
}

/// Mensajes de estado.
class _StatusMessages {
  static const String preparing = 'Preparando envío...';
  static const String uploadingFiles = 'Subiendo archivos...';
  static const String filesUploaded = 'Archivos subidos correctamente';
  static const String uploadError = 'Error subiendo archivos';
  static const String sendingNotification = 'Enviando notificación...';
  static const String infoSent = 'Información enviada correctamente';
  static const String sendError = 'Error al enviar la información';
  static const String ready = 'Listo';

  static String uploadingProgress(double progress) {
    return 'Subiendo archivos: ${(progress * 100).toStringAsFixed(0)}%';
  }
}

/// Claves para acceder a datos del response.
class _ResponseKeys {
  // Versace
  static const String idInformeFechas = 'id_informe_fechas';
  static const String idDirma = 'id_dirma';
  static const String idInformePasado = 'id_informe_pasado';
  static const String idInformeNuevo = 'id_informe_nuevo';
  // Stuart Weitzman
  static const String idsPdfs = 'ids_pdfs';
  static const String idExcel = 'id_excel';
  static const String mes = 'mes';
  static const String anio = 'anio';
  static const String coleccion = 'coleccion';
}

/// Configuración de años disponibles.
class _YearConfig {
  static const int minYear = 2020;

  static List<String> generateYears() {
    final maxYear = DateTime.now().year + 1;
    return [
      for (int i = maxYear; i >= minYear; i--) i.toString(),
    ];
  }
}

/// Lista de meses del año con sus valores numéricos.
class _MonthsList {
  static const Map<String, String> monthsMap = {
    'Enero': '01',
    'Febrero': '02',
    'Marzo': '03',
    'Abril': '04',
    'Mayo': '05',
    'Junio': '06',
    'Julio': '07',
    'Agosto': '08',
    'Septiembre': '09',
    'Octubre': '10',
    'Noviembre': '11',
    'Diciembre': '12',
  };

  static List<String> get names => monthsMap.keys.toList();

  static String? getNumericValue(String? monthName) {
    return monthName != null ? monthsMap[monthName] : null;
  }
}

/// Dimensiones responsive.
class _ResponsiveDimensions {
  static const double maxFormWidth = 800.0;
  static const double mobileWatermarkSizeFactor = 0.4;
  static const double desktopWatermarkSizeFactor = 0.5;
  static const double mobileWatermarkSizePx = 240.0;
  static const double desktopWatermarkSizePx = 360.0;
  static const double mobilePaddingVertical = 24.0;
  static const double desktopPaddingVertical = 40.0;
}

/// Tamaños de fuente personalizados.
class _CustomFontSizes {
  static const double progressText = 12.0;
  static const double statusText = 13.0;
  static const double errorText = 12.0;
}

/// Textos de la interfaz.
class _UITexts {
  static const String title = 'SITUACIÓN PEDIDOS';
  static const String marcaLabel = 'Marca';
  // Versace
  static const String informeFechasLabel = 'Informe Fechas (PDF)';
  static const String dirmaLabel = 'DIRMA (Excel)';
  static const String informePasadoLabel = 'Informe Pasado (Excel)';
  static const String informeNuevoLabel = 'Informe Nuevo (Excel)';
  // Stuart Weitzman
  static const String yearLabel = 'Año';
  static const String monthLabel = 'Mes';
  static const String coleccionLabel = 'Colección';
  static const String erpSusyLabel = 'ERP SUSY (PDF)';
  static const String planningClienteLabel = 'Planning Cliente (Excel)';
  // Botones
  static const String submitButton = 'Enviar';
  static const String submitButtonLoading = 'Enviando...';
}

// ============================================
// PÁGINA PRINCIPAL
// ============================================

class SituacionPedidosPage extends StatelessWidget {
  const SituacionPedidosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppBreakpoints.mobile;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: ViewportWatermarkWidget(
        asset: _IconAssets.watermark,
        sizeFactor: isMobile
            ? _ResponsiveDimensions.mobileWatermarkSizeFactor
            : _ResponsiveDimensions.desktopWatermarkSizeFactor,
        sizePx: isMobile
            ? _ResponsiveDimensions.mobileWatermarkSizePx
            : _ResponsiveDimensions.desktopWatermarkSizePx,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? AppSpacing.large : AppSpacing.xxl,
                vertical: isMobile
                    ? _ResponsiveDimensions.mobilePaddingVertical
                    : _ResponsiveDimensions.desktopPaddingVertical,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _ResponsiveDimensions.maxFormWidth,
                  ),
                  child: const _SituacionPedidosForm(),
                ),
              ),
            ),
            const FloatingBackButton(),
          ],
        ),
      ),
    );
  }
}

// ============================================
// FORMULARIO DE SITUACIÓN PEDIDOS
// ============================================

class _SituacionPedidosForm extends StatefulWidget {
  const _SituacionPedidosForm();

  @override
  State<_SituacionPedidosForm> createState() => _SituacionPedidosFormState();
}

class _SituacionPedidosFormState extends State<_SituacionPedidosForm> {
  // Estado del formulario
  String? _marcaSeleccionada;

  // Archivos Versace
  PlatformFile? _informeFechas;
  PlatformFile? _dirma;
  PlatformFile? _informePasado;
  PlatformFile? _informeNuevo;

  // Campos Stuart Weitzman
  String? _selectedYear;
  String? _selectedMonth;
  String? _selectedColeccion;
  List<PlatformFile> _erpSusy = [];
  PlatformFile? _planningCliente;

  // Estado de la subida
  bool _isSending = false;
  bool _isUploadingFiles = false;
  double _uploadProgress = 0.0;
  String _statusMsg = '';

  // Errores de validación por campo
  Map<String, String?> _fieldErrors = {};

  // Listas precalculadas
  late final List<String> _years = _YearConfig.generateYears();

  // ============================================
  // VALIDACIÓN
  // ============================================

  bool _validateFields() {
    final errors = <String, String?>{};

    if (_marcaSeleccionada == null || _marcaSeleccionada!.trim().isEmpty) {
      errors[_FormFields.marca] = _ValidationMessages.marcaRequired;
    }

    if (_marcaSeleccionada == _BrandsList.versace) {
      // Validar archivos de Versace
      if (_informeFechas == null) {
        errors[_FormFields.informeFechas] =
            _ValidationMessages.informeFechasRequired;
      }
      if (_dirma == null) {
        errors[_FormFields.dirma] = _ValidationMessages.dirmaRequired;
      }
      if (_informePasado == null) {
        errors[_FormFields.informePasado] =
            _ValidationMessages.informePasadoRequired;
      }
      if (_informeNuevo == null) {
        errors[_FormFields.informeNuevo] =
            _ValidationMessages.informeNuevoRequired;
      }
    } else if (_marcaSeleccionada == _BrandsList.stuartWeitzman) {
      // Validar campos de Stuart Weitzman
      if (_selectedYear == null || _selectedYear!.trim().isEmpty) {
        errors[_FormFields.year] = _ValidationMessages.yearRequired;
      }
      if (_selectedMonth == null || _selectedMonth!.trim().isEmpty) {
        errors[_FormFields.month] = _ValidationMessages.monthRequired;
      }
      if (_selectedColeccion == null || _selectedColeccion!.trim().isEmpty) {
        errors[_FormFields.coleccion] = _ValidationMessages.coleccionRequired;
      }
      if (_erpSusy.isEmpty) {
        errors[_FormFields.erpSusy] = _ValidationMessages.erpSusyRequired;
      }
      if (_planningCliente == null) {
        errors[_FormFields.planningCliente] =
            _ValidationMessages.planningClienteRequired;
      }
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
  // SUBIDA DE ARCHIVOS
  // ============================================

  Future<Map<String, dynamic>> _uploadFiles() async {
    setState(() {
      _isUploadingFiles = true;
      _uploadProgress = 0.0;
      _statusMsg = _StatusMessages.uploadingFiles;
    });

    try {
      if (_marcaSeleccionada == _BrandsList.versace) {
        return await _uploadVersaceFiles();
      } else {
        return await _uploadSWFiles();
      }
    } catch (e) {
      _handleUploadError(e);
      rethrow;
    } finally {
      setState(() {
        _isUploadingFiles = false;
        _uploadProgress = 0.0;
      });
    }
  }

  Future<Map<String, dynamic>> _uploadVersaceFiles() async {
    final response = await DioClient.uploadExcelSituacionVersace(
      informeFechas: _informeFechas!,
      dirma: _dirma!,
      informePasado: _informePasado!,
      informeNuevo: _informeNuevo!,
      onSendProgress: _updateUploadProgress,
    );

    final uploadResult = Map<String, dynamic>.from(response.data as Map);
    setState(() => _statusMsg = _StatusMessages.filesUploaded);

    return uploadResult;
  }

  Future<Map<String, dynamic>> _uploadSWFiles() async {
    final response = await DioClient.uploadExcelSituacionSW(
      erpSusy: _erpSusy,
      planningCliente: _planningCliente!,
      onSendProgress: _updateUploadProgress,
    );

    final uploadResult = Map<String, dynamic>.from(response.data as Map);
    setState(() => _statusMsg = _StatusMessages.filesUploaded);

    return uploadResult;
  }

  void _updateUploadProgress(int sent, int total) {
    if (total > 0) {
      setState(() => _uploadProgress = sent / total);
    }
  }

  void _handleUploadError(Object error) {
    setState(() => _statusMsg = _StatusMessages.uploadError);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_StatusMessages.uploadError}: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ============================================
  // CONSTRUCCIÓN DEL PAYLOAD
  // ============================================

  Map<String, dynamic> _buildPayloadVersace(Map<String, dynamic> uploadResult) {
    return {
      'data': {
        'marca': _marcaSeleccionada,
        _ResponseKeys.idInformeFechas:
            uploadResult[_ResponseKeys.idInformeFechas],
        _ResponseKeys.idDirma: uploadResult[_ResponseKeys.idDirma],
        _ResponseKeys.idInformePasado:
            uploadResult[_ResponseKeys.idInformePasado],
        _ResponseKeys.idInformeNuevo:
            uploadResult[_ResponseKeys.idInformeNuevo],
      },
    };
  }

  Map<String, dynamic> _buildPayloadSW(Map<String, dynamic> uploadResult) {
    // Obtener el valor numérico del mes (01, 02, etc.)
    final mesNumerico = _MonthsList.getNumericValue(_selectedMonth);

    return {
      'data': {
        'marca': _marcaSeleccionada,
        _ResponseKeys.anio: _selectedYear,
        _ResponseKeys.mes: mesNumerico,
        _ResponseKeys.coleccion: _selectedColeccion,
        _ResponseKeys.idsPdfs: uploadResult[_ResponseKeys.idsPdfs],
        _ResponseKeys.idExcel: uploadResult[_ResponseKeys.idExcel],
      },
    };
  }

  // ============================================
  // ENVÍO A MAKE
  // ============================================

  Future<void> _sendToMake(Map<String, dynamic> uploadResult) async {
    setState(() => _statusMsg = _StatusMessages.sendingNotification);

    final payload = _marcaSeleccionada == _BrandsList.versace
        ? _buildPayloadVersace(uploadResult)
        : _buildPayloadSW(uploadResult);

    final endpoint = _marcaSeleccionada == _BrandsList.versace
        ? _SituacionPedidosEndpoints.makeWebhookVersace
        : _SituacionPedidosEndpoints.makeWebhookSW;

    await JsonSender.sendToMake(
      payload,
      endpoint: endpoint,
    );
  }

  // ============================================
  // MANEJO DEL ENVÍO COMPLETO
  // ============================================

  Future<void> _handleEnviar() async {
    if (!_validateFields()) {
      _showValidationError();
      return;
    }

    setState(() {
      _isSending = true;
      _statusMsg = _StatusMessages.preparing;
    });

    try {
      final uploadResult = await _uploadFiles();
      await _sendToMake(uploadResult);
      _handleSuccessfulSubmission();
    } catch (e) {
      _handleSubmissionError(e);
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _showValidationError() {
    final errorMessage = _buildValidationErrorMessage();
    setState(() => _statusMsg = errorMessage);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleSuccessfulSubmission() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(_StatusMessages.infoSent),
        backgroundColor: AppColors.success,
      ),
    );

    _clearForm();
    Navigator.of(context).pop();
  }

  void _handleSubmissionError(Object error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_StatusMessages.sendError}: $error'),
        backgroundColor: AppColors.error,
      ),
    );

    setState(() => _statusMsg = _StatusMessages.sendError);
  }

  void _clearForm() {
    setState(() {
      _marcaSeleccionada = null;
      _informeFechas = null;
      _dirma = null;
      _informePasado = null;
      _informeNuevo = null;
      _selectedYear = null;
      _selectedMonth = null;
      _selectedColeccion = null;
      _erpSusy = [];
      _planningCliente = null;
      _statusMsg = _StatusMessages.ready;
      _fieldErrors = {};
    });
  }

  // ============================================
  // BUILD UI
  // ============================================

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppBreakpoints.mobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(context),
        const SizedBox(height: AppSpacing.xl),
        _buildMarcaField(),
        const SizedBox(height: AppSpacing.xl),
        if (_marcaSeleccionada != null) ..._buildDynamicFields(isMobile),
        if (_marcaSeleccionada != null) ...[
          const SizedBox(height: AppSpacing.large),
          if (_isUploadingFiles) _buildUploadProgress(),
          const SizedBox(height: AppSpacing.large),
          _buildDivider(),
          const SizedBox(height: AppSpacing.medium),
          if (_statusMsg.isNotEmpty) _buildStatusMessage(),
          _buildSubmitButton(),
        ],
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Center(
      child: Text(
        _UITexts.title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: AppFontWeights.bold,
            ),
      ),
    );
  }

  Widget _buildMarcaField() {
    return CustomDropdown(
      label: _UITexts.marcaLabel,
      items: _BrandsList.all,
      selectedValue: _marcaSeleccionada,
      isEnabled: !_isSending,
      onChanged: (value) {
        setState(() {
          _marcaSeleccionada = value;
          // Limpiar archivos y campos cuando cambia la marca
          _informeFechas = null;
          _dirma = null;
          _informePasado = null;
          _informeNuevo = null;
          _selectedYear = null;
          _selectedMonth = null;
          _selectedColeccion = null;
          _erpSusy = [];
          _planningCliente = null;
          _fieldErrors = {};
        });
      },
      errorText: _fieldErrors[_FormFields.marca],
    );
  }

  List<Widget> _buildDynamicFields(bool isMobile) {
    if (_marcaSeleccionada == _BrandsList.versace) {
      return _buildVersaceFields();
    } else if (_marcaSeleccionada == _BrandsList.stuartWeitzman) {
      return _buildStuartWeitzmanFields(isMobile);
    }
    return [];
  }

  List<Widget> _buildVersaceFields() {
    return [
      _buildInformeFechasField(),
      _buildFieldError(_FormFields.informeFechas),
      const SizedBox(height: AppSpacing.xl),
      _buildDirmaField(),
      _buildFieldError(_FormFields.dirma),
      const SizedBox(height: AppSpacing.xl),
      _buildInformePasadoField(),
      _buildFieldError(_FormFields.informePasado),
      const SizedBox(height: AppSpacing.xl),
      _buildInformeNuevoField(),
      _buildFieldError(_FormFields.informeNuevo),
    ];
  }

  List<Widget> _buildStuartWeitzmanFields(bool isMobile) {
    return [
      _buildYearMonthColeccionFields(isMobile),
      const SizedBox(height: AppSpacing.xl),
      _buildErpSusyField(),
      _buildFieldError(_FormFields.erpSusy),
      const SizedBox(height: AppSpacing.xl),
      _buildPlanningClienteField(),
      _buildFieldError(_FormFields.planningCliente),
    ];
  }

  // ============================================
  // CAMPOS VERSACE
  // ============================================

  Widget _buildInformeFechasField() {
    return SingleFilePicker(
      label: _UITexts.informeFechasLabel,
      iconAssetPath: _IconAssets.pdf,
      allowedExtensions: _FileExtensions.pdf,
      selectedFile: _informeFechas,
      onFileSelected: (file) => setState(() => _informeFechas = file),
    );
  }

  Widget _buildDirmaField() {
    return SingleFilePicker(
      label: _UITexts.dirmaLabel,
      iconAssetPath: _IconAssets.excel,
      allowedExtensions: _FileExtensions.excel,
      selectedFile: _dirma,
      onFileSelected: (file) => setState(() => _dirma = file),
    );
  }

  Widget _buildInformePasadoField() {
    return SingleFilePicker(
      label: _UITexts.informePasadoLabel,
      iconAssetPath: _IconAssets.excel,
      allowedExtensions: _FileExtensions.excel,
      selectedFile: _informePasado,
      onFileSelected: (file) => setState(() => _informePasado = file),
    );
  }

  Widget _buildInformeNuevoField() {
    return SingleFilePicker(
      label: _UITexts.informeNuevoLabel,
      iconAssetPath: _IconAssets.excel,
      allowedExtensions: _FileExtensions.excel,
      selectedFile: _informeNuevo,
      onFileSelected: (file) => setState(() => _informeNuevo = file),
    );
  }

  // ============================================
  // CAMPOS STUART WEITZMAN
  // ============================================

  Widget _buildYearMonthColeccionFields(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildYearField(),
          const SizedBox(height: AppSpacing.large),
          _buildMonthField(),
          const SizedBox(height: AppSpacing.large),
          _buildColeccionField(),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildYearField()),
            const SizedBox(width: AppSpacing.large),
            Expanded(child: _buildMonthField()),
          ],
        ),
        const SizedBox(height: AppSpacing.large),
        _buildColeccionField(),
      ],
    );
  }

  Widget _buildYearField() {
    return CustomDropdown(
      label: _UITexts.yearLabel,
      items: _years,
      selectedValue: _selectedYear,
      isEnabled: !_isSending,
      onChanged: (value) => setState(() => _selectedYear = value),
      errorText: _fieldErrors[_FormFields.year],
    );
  }

  Widget _buildMonthField() {
    return CustomDropdown(
      label: _UITexts.monthLabel,
      items: _MonthsList.names,
      selectedValue: _selectedMonth,
      isEnabled: !_isSending,
      onChanged: (value) => setState(() => _selectedMonth = value),
      errorText: _fieldErrors[_FormFields.month],
    );
  }

  Widget _buildColeccionField() {
    return CustomDropdown(
      label: _UITexts.coleccionLabel,
      items: _CollectionOptions.all,
      selectedValue: _selectedColeccion,
      isEnabled: !_isSending,
      onChanged: (value) => setState(() => _selectedColeccion = value),
      errorText: _fieldErrors[_FormFields.coleccion],
    );
  }

  Widget _buildErpSusyField() {
    return MultiFileGroupPicker(
      groupTitle: _UITexts.erpSusyLabel,
      iconAssetPath: _IconAssets.pdf,
      allowedExtensions: _FileExtensions.pdf,
      selectedFiles: _erpSusy,
      onFilesSelected: (files) => setState(() => _erpSusy = files),
    );
  }

  Widget _buildPlanningClienteField() {
    return SingleFilePicker(
      label: _UITexts.planningClienteLabel,
      iconAssetPath: _IconAssets.excel,
      allowedExtensions: _FileExtensions.excel,
      selectedFile: _planningCliente,
      onFileSelected: (file) => setState(() => _planningCliente = file),
    );
  }

  // ============================================
  // WIDGETS AUXILIARES
  // ============================================

  Widget _buildFieldError(String fieldKey) {
    final error = _fieldErrors[fieldKey];
    if (error == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.small),
      child: Text(
        error,
        style: const TextStyle(
          color: AppColors.error,
          fontSize: _CustomFontSizes.errorText,
        ),
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Column(
      children: [
        LinearProgressIndicator(value: _uploadProgress),
        const SizedBox(height: AppSpacing.small),
        Text(
          _StatusMessages.uploadingProgress(_uploadProgress),
          style: const TextStyle(
            fontSize: _CustomFontSizes.progressText,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
      ],
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: AppColors.accent,
      thickness: AppBorderWidth.normal,
    );
  }

  Widget _buildStatusMessage() {
    final isError = _statusMsg.toLowerCase().contains('error');

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

  Widget _buildSubmitButton() {
    return PrimaryButton(
      text: _isSending ? _UITexts.submitButtonLoading : _UITexts.submitButton,
      onPressed: _handleEnviar,
      isLoading: _isSending,
    );
  }
}