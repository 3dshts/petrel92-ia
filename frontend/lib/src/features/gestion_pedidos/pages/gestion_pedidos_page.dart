// frontend/lib/src/features/gestor_pedidos/pages/gestor_pedidos_page.dart

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/common_widgets/custom_app_bar.dart';
import '../../../core/common_widgets/decorative_corner_icon.dart';
import '../../../core/common_widgets/single_file_picker.dart';
import '../../../core/common_widgets/primary_button.dart';
import '../../../core/common_widgets/floating_back_button.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/json_sender.dart';
import '../../../core/network/dio_client.dart';

// ============================================
// CONSTANTES
// ============================================

/// Endpoints externos de la aplicación.
class _PedidosEndpoints {
  static const String makeWebhook =
      'https://hook.eu2.make.com/tksvebdvx6moxij6e19lvc383meievao';
}

/// Extensiones permitidas para archivos PDF.
class _PdfExtensions {
  static const List<String> allowed = ['pdf'];
}

/// Assets de iconos.
class _IconAssets {
  static const String pdf = 'assets/component_icons/pdf_icon.svg';
  static const String watermark = 'assets/dashboard_icons/gestor_pedidos.svg';
}

/// Claves de campos del formulario.
class _FormFields {
  static const String archivoPdf = 'archivo_pdf';
}

/// Labels legibles de los campos.
class _FieldLabels {
  static const Map<String, String> map = {
    _FormFields.archivoPdf: 'Archivo PDF',
  };
}

/// Mensajes de validación.
class _ValidationMessages {
  static const String pdfRequired = 'Selecciona un archivo PDF.';

  static String buildAggregateError(List<String> missingFields) {
    return 'Faltan los campos: ${missingFields.join(', ')}.';
  }
}

/// Mensajes de estado.
class _StatusMessages {
  static const String preparing = 'Preparando envío...';
  static const String uploadingPdf = 'Subiendo PDF...';
  static const String pdfUploaded = 'PDF subido correctamente';
  static const String uploadError = 'Error subiendo PDF';
  static const String sendingOrder = 'Enviando pedido...';
  static const String orderSent = 'Pedido enviado correctamente';
  static const String orderError = 'Error al enviar pedido';
  static const String ready = 'Listo';

  static String uploadingProgress(double progress) {
    return 'Subiendo PDF: ${(progress * 100).toStringAsFixed(0)}%';
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
}

/// Textos de la interfaz.
class _UITexts {
  static const String title = 'GESTOR PEDIDOS';
  static const String pdfLabel = 'Pedido Cliente (PDF)';
  static const String submitButton = 'Enviar';
  static const String submitButtonLoading = 'Enviando...';
}

/// Claves para acceder a datos del response.
class _ResponseKeys {
  static const String pdf = 'pdf';
  static const String id = 'id';
  static const String pdfId = 'PDF_ID';
}

// ============================================
// PÁGINA PRINCIPAL
// ============================================

class GestionPedidosPage extends StatelessWidget {
  const GestionPedidosPage({super.key});

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
                  child: const _PedidosForm(),
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
// FORMULARIO DE PEDIDOS
// ============================================

class _PedidosForm extends StatefulWidget {
  const _PedidosForm();

  @override
  State<_PedidosForm> createState() => _PedidosFormState();
}

class _PedidosFormState extends State<_PedidosForm> {
  // Estado del formulario
  PlatformFile? _archivoPDF;

  // Estado de la subida
  bool _isSending = false;
  bool _isUploadingPdf = false;
  double _uploadProgress = 0.0;
  String _statusMsg = '';

  // Errores de validación por campo
  Map<String, String?> _fieldErrors = {};

  // ============================================
  // VALIDACIÓN
  // ============================================

  bool _validateFields() {
    final errors = <String, String?>{};

    if (_archivoPDF == null) {
      errors[_FormFields.archivoPdf] = _ValidationMessages.pdfRequired;
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
  // SUBIDA DE PDF
  // ============================================

  Future<Map<String, dynamic>> _uploadPdf() async {
    setState(() {
      _isUploadingPdf = true;
      _uploadProgress = 0.0;
      _statusMsg = _StatusMessages.uploadingPdf;
    });

    try {
      final response = await DioClient.uploadPedidoPdf(
        file: _archivoPDF!,
        onSendProgress: _updateUploadProgress,
      );

      setState(() => _statusMsg = _StatusMessages.pdfUploaded);

      final responseData = Map<String, dynamic>.from(response.data as Map);
      return responseData[_ResponseKeys.pdf] as Map<String, dynamic>;
    } catch (e) {
      _handleUploadError(e);
      rethrow;
    } finally {
      setState(() {
        _isUploadingPdf = false;
        _uploadProgress = 0.0;
      });
    }
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

  Map<String, dynamic> _buildPayload(Map<String, dynamic> pdfMeta) {
    return {
      'data': {
        _ResponseKeys.pdfId: pdfMeta[_ResponseKeys.id],
      },
    };
  }

  // ============================================
  // ENVÍO A MAKE
  // ============================================

  Future<void> _sendToMake(Map<String, dynamic> pdfMeta) async {
    setState(() => _statusMsg = _StatusMessages.sendingOrder);

    final payload = _buildPayload(pdfMeta);

    await JsonSender.sendToMake(
      payload,
      endpoint: _PedidosEndpoints.makeWebhook,
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
      final pdfMeta = await _uploadPdf();
      await _sendToMake(pdfMeta);
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
        content: Text(_StatusMessages.orderSent),
        backgroundColor: AppColors.success,
      ),
    );

    _clearForm();
    Navigator.of(context).pop();
  }

  void _handleSubmissionError(Object error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(_StatusMessages.orderError),
        backgroundColor: AppColors.error,
      ),
    );

    setState(() => _statusMsg = _StatusMessages.orderError);
  }

  void _clearForm() {
    setState(() {
      _archivoPDF = null;
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
        _buildPdfField(),
        const SizedBox(height: AppSpacing.large),
        if (_isUploadingPdf) _buildUploadProgress(),
        const SizedBox(height: AppSpacing.large),
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


  Widget _buildPdfField() {
    return SingleFilePicker(
      label: _UITexts.pdfLabel,
      iconAssetPath: _IconAssets.pdf,
      allowedExtensions: _PdfExtensions.allowed,
      selectedFile: _archivoPDF,
      onFileSelected: (file) => setState(() => _archivoPDF = file),
      enabled: !_isSending,
      errorText: _fieldErrors[_FormFields.archivoPdf],
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