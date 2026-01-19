// frontend/lib/src/features/prototipos/pages/prototipos_page.dart

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/common_widgets/custom_app_bar.dart';
import '../../../core/common_widgets/custom_dropdown.dart';
import '../../../core/common_widgets/single_file_picker.dart';
import '../../../core/common_widgets/primary_button.dart';
import '../../../core/common_widgets/floating_back_button.dart';
import '../../../core/common_widgets/decorative_corner_icon.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/json_sender.dart';
import '../../../core/network/dio_client.dart';

// ============================================
// CONSTANTES
// ============================================

/// Endpoints externos de la aplicación.
class _PrototiposEndpoints {
  static const String makeWebhook =
      'https://hook.eu2.make.com/bfb7nkaptzniqljznr5v3lwrmby345st';
}

/// Marcas disponibles en el sistema.
class _BrandsList {
  static const List<String> all = [
    'STUART WEITZMAN',
    'VERSACE',
  ];
}

/// Extensiones permitidas para archivos Excel.
class _ExcelExtensions {
  static const List<String> allowed = ['xls', 'xlsx', 'xlsm'];
}

/// Assets de iconos.
class _IconAssets {
  static const String excel = 'assets/component_icons/excel_icon.svg';
  static const String watermark = 'assets/dashboard_icons/prototipos.svg';
}

/// Claves de campos del formulario.
class _FormFields {
  static const String marca = 'marca';
  static const String archivo = 'archivo';
}

/// Labels legibles de los campos.
class _FieldLabels {
  static const Map<String, String> map = {
    _FormFields.marca: 'Marca',
    _FormFields.archivo: 'Archivo Excel',
  };
}

/// Mensajes de validación.
class _ValidationMessages {
  static const String marcaRequired = 'Selecciona una marca.';
  static const String archivoRequired = 'Selecciona un archivo Excel.';

  static String buildAggregateError(List<String> missingFields) {
    return 'Faltan los campos: ${missingFields.join(', ')}.';
  }
}

/// Mensajes de estado.
class _StatusMessages {
  static const String preparing = 'Preparando envío...';
  static const String uploadingExcel = 'Subiendo Excel y extrayendo imágenes...';
  static const String uploadError = 'Error subiendo Excel';
  static const String sendingToMake = 'Enviando a Make...';
  static const String dataSentToMake = 'Datos enviados a Make correctamente.';
  static const String sendError = 'Error al enviar a Make';
  static const String ready = 'Listo';

  static String uploadingProgress(double progress) {
    return 'Subiendo Excel: ${(progress * 100).toStringAsFixed(0)}%';
  }

  static String excelUploadedWithImages(int imageCount) {
    return 'Excel subido correctamente. $imageCount imágenes extraídas.';
  }

  static String successWithMessage(String message) {
    return 'Éxito: $message';
  }
}

/// Claves para acceder a datos del response.
class _ResponseKeys {
  static const String message = 'message';
  static const String idArchivo = 'id_archivo';
  static const String nombreArchivo = 'nombre_archivo';
  static const String idImagen = 'id_imagen';
  static const String marca = 'marca';
  static const String archivos = 'archivos';
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
}

/// Textos de la interfaz.
class _UITexts {
  static const String title = 'PROTOTIPOS';
  static const String marcaLabel = 'Marca del Prototipo';
  static const String archivoLabel = 'Ficha Técnica (Excel)';
  static const String submitButton = 'Enviar';
  static const String submitButtonLoading = 'Enviando...';
}

// ============================================
// PÁGINA PRINCIPAL
// ============================================

class PrototiposPage extends StatelessWidget {
  const PrototiposPage({super.key});

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
                  child: const _PrototiposForm(),
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
// FORMULARIO DE PROTOTIPOS
// ============================================

class _PrototiposForm extends StatefulWidget {
  const _PrototiposForm();

  @override
  State<_PrototiposForm> createState() => _PrototiposFormState();
}

class _PrototiposFormState extends State<_PrototiposForm> {
  // Estado del formulario
  String? _marcaSeleccionada;
  PlatformFile? _archivoExcel;

  // Estado de la subida
  bool _isSending = false;
  bool _isUploadingExcel = false;
  double _uploadProgress = 0.0;
  String _statusMsg = '';

  // Errores de validación por campo
  Map<String, String?> _fieldErrors = {};

  // ============================================
  // VALIDACIÓN
  // ============================================

  bool _validateFields() {
    final errors = <String, String?>{};

    if (_marcaSeleccionada == null || _marcaSeleccionada!.trim().isEmpty) {
      errors[_FormFields.marca] = _ValidationMessages.marcaRequired;
    }

    if (_archivoExcel == null) {
      errors[_FormFields.archivo] = _ValidationMessages.archivoRequired;
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
  // SUBIDA DE EXCEL
  // ============================================

  Future<Map<String, dynamic>> _uploadExcel() async {
    setState(() {
      _isUploadingExcel = true;
      _uploadProgress = 0.0;
      _statusMsg = _StatusMessages.uploadingExcel;
    });

    try {
      final response = await DioClient.uploadPrototypeExcel(
        file: _archivoExcel!,
        marca: _marcaSeleccionada!,
        onSendProgress: _updateUploadProgress,
      );

      // El backend retorna: { message, id_archivo, nombre_archivo, id_imagen }
      final driveData = Map<String, dynamic>.from(response.data as Map);
      _updateStatusAfterUpload(driveData);

      return driveData;
    } catch (e) {
      _handleUploadError(e);
      rethrow;
    } finally {
      setState(() {
        _isUploadingExcel = false;
        _uploadProgress = 0.0;
      });
    }
  }

  void _updateUploadProgress(int sent, int total) {
    if (total > 0) {
      setState(() => _uploadProgress = sent / total);
    }
  }

  void _updateStatusAfterUpload(Map<String, dynamic> driveData) {
    // id_imagen contiene { archivos: [...] }
    final idImagen = driveData[_ResponseKeys.idImagen] as Map<String, dynamic>?;
    final archivos = idImagen?[_ResponseKeys.archivos] as List?;
    final imagesCount = archivos?.length ?? 0;

    setState(() {
      _statusMsg = _StatusMessages.excelUploadedWithImages(imagesCount);
    });
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

  Map<String, dynamic> _buildPayload(Map<String, dynamic> driveData) {
    return {
      'data': {
        _ResponseKeys.marca: _marcaSeleccionada,
        _ResponseKeys.idArchivo: driveData[_ResponseKeys.idArchivo],
        _ResponseKeys.nombreArchivo: driveData[_ResponseKeys.nombreArchivo],
        _ResponseKeys.idImagen: driveData[_ResponseKeys.idImagen],
      },
    };
  }

  // ============================================
  // ENVÍO A MAKE
  // ============================================

  Future<void> _sendToMake(Map<String, dynamic> driveData) async {
    setState(() => _statusMsg = _StatusMessages.sendingToMake);

    final payload = _buildPayload(driveData);

    await JsonSender.sendToMake(
      payload,
      endpoint: _PrototiposEndpoints.makeWebhook,
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
      final driveData = await _uploadExcel();
      await _sendToMake(driveData);
      _handleSuccessfulSubmission(driveData);
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

  void _handleSuccessfulSubmission(Map<String, dynamic> driveData) {
    if (!mounted) return;

    final message = _buildSuccessMessage(driveData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );

    _clearForm();
    Navigator.of(context).pop();
  }

  String _buildSuccessMessage(Map<String, dynamic> driveData) {
    final message = driveData[_ResponseKeys.message] as String?;
    
    if (message != null && message.isNotEmpty) {
      return _StatusMessages.successWithMessage(message);
    }
    
    return _StatusMessages.dataSentToMake;
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
      _archivoExcel = null;
      _statusMsg = _StatusMessages.ready;
      _fieldErrors = {};
    });
  }

  // ============================================
  // BUILD UI
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(context),
        const SizedBox(height: AppSpacing.xl),
        _buildMarcaField(),
        const SizedBox(height: AppSpacing.xl),
        _buildArchivoField(),
        const SizedBox(height: AppSpacing.large),
        if (_isUploadingExcel) _buildUploadProgress(),
        _buildDivider(),
        const SizedBox(height: AppSpacing.medium),
        if (_statusMsg.isNotEmpty) _buildStatusMessage(),
        _buildSubmitButton(),
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
      onChanged: (value) => setState(() => _marcaSeleccionada = value),
      errorText: _fieldErrors[_FormFields.marca],
    );
  }

  Widget _buildArchivoField() {
    return SingleFilePicker(
      label: _UITexts.archivoLabel,
      iconAssetPath: _IconAssets.excel,
      allowedExtensions: _ExcelExtensions.allowed,
      selectedFile: _archivoExcel,
      onFileSelected: (file) => setState(() => _archivoExcel = file),
      enabled: !_isSending,
      errorText: _fieldErrors[_FormFields.archivo],
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