// frontend/lib/src/features/fabricacion/widgets/comment_form_dialog.dart

import 'package:flutter/material.dart';
import '../../../core/models/calendar_comment_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/common_widgets/common_text_field.dart';
import '../../../core/common_widgets/common_multiline_text_field.dart';
import 'package:intl/intl.dart';

/// Muestra el dialog para crear o editar un comentario.
Future<void> showCommentFormDialog({
  required BuildContext context,
  required DateTime selectedDate,
  required String autorNombre,
  required Function(String titulo, String comentario) onSave,
  CalendarCommentModel? commentToEdit,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => CommentFormDialog(
      selectedDate: selectedDate,
      autorNombre: autorNombre,
      onSave: onSave,
      commentToEdit: commentToEdit,
    ),
  );
}

/// Dialog para crear o editar un comentario del calendario.
///
/// Modos de uso:
/// - Crear: No pasar [commentToEdit]
/// - Editar: Pasar [commentToEdit] con el comentario a editar
class CommentFormDialog extends StatefulWidget {
  const CommentFormDialog({
    super.key,
    required this.selectedDate,
    required this.autorNombre,
    required this.onSave,
    this.commentToEdit,
  });

  /// Fecha del comentario (no editable).
  final DateTime selectedDate;

  /// Nombre del autor actual (no editable).
  final String autorNombre;

  /// Callback ejecutado al guardar.
  /// Parámetros: (titulo, comentario)
  final Function(String titulo, String comentario) onSave;

  /// Comentario a editar (null si es creación).
  final CalendarCommentModel? commentToEdit;

  @override
  State<CommentFormDialog> createState() => _CommentFormDialogState();
}

class _CommentFormDialogState extends State<CommentFormDialog> {
  final _tituloController = TextEditingController();
  final _comentarioController = TextEditingController();

  bool _isSaving = false;
  String? _tituloError;
  String? _comentarioError;

  @override
  void initState() {
    super.initState();
    
    // Si es edición, pre-cargar los datos
    if (widget.commentToEdit != null) {
      _tituloController.text = widget.commentToEdit!.titulo;
      _comentarioController.text = widget.commentToEdit!.comentario;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  /// Valida el formulario.
  bool _validateForm() {
    setState(() {
      _tituloError = null;
      _comentarioError = null;
    });

    bool isValid = true;

    if (_tituloController.text.trim().isEmpty) {
      setState(() => _tituloError = 'El título es obligatorio');
      isValid = false;
    } else if (_tituloController.text.trim().length > 200) {
      setState(() => _tituloError = 'El título no puede superar 200 caracteres');
      isValid = false;
    }

    if (_comentarioController.text.trim().isEmpty) {
      setState(() => _comentarioError = 'El comentario es obligatorio');
      isValid = false;
    }

    return isValid;
  }

  /// Guarda el comentario.
  Future<void> _handleSave() async {
    if (!_validateForm()) return;

    setState(() => _isSaving = true);

    try {
      await widget.onSave(
        _tituloController.text.trim(),
        _comentarioController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppBreakpoints.mobile;
    final isEditing = widget.commentToEdit != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 500.0,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(isEditing),
                const SizedBox(height: AppSpacing.large),
                _buildDateField(),
                const SizedBox(height: AppSpacing.medium),
                _buildTitleField(),
                const SizedBox(height: AppSpacing.medium),
                _buildCommentField(),
                const SizedBox(height: AppSpacing.medium),
                _buildAuthorField(),
                const SizedBox(height: AppSpacing.xl),
                _buildButtons(context, isEditing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Header del dialog.
  Widget _buildHeader(bool isEditing) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.small),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.small),
          ),
          child: Icon(
            isEditing ? Icons.edit : Icons.add_comment,
            color: AppColors.primary,
            size: 24.0,
          ),
        ),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: Text(
            isEditing ? 'Editar Comentario' : 'Añadir Comentario',
            style: TextStyle(
              fontSize: AppFontSizes.large,
              fontWeight: AppFontWeights.bold,
              color: AppColors.text,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          color: AppColors.text.withOpacity(0.6),
        ),
      ],
    );
  }

  /// Campo de fecha (no editable).
  Widget _buildDateField() {
    final formattedDate = DateFormat('dd/MM/yyyy').format(widget.selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.small),
          child: Text(
            'Fecha',
            style: AppTextStyles.label,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.medium,
            vertical: AppSpacing.medium,
          ),
          decoration: BoxDecoration(
            color: AppColors.cardBorder.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(
              color: AppColors.cardBorder,
              width: AppBorderWidth.thin,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 20.0,
                color: AppColors.text.withOpacity(0.6),
              ),
              const SizedBox(width: AppSpacing.small),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: AppFontSizes.medium,
                  color: AppColors.text.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Campo de título.
  Widget _buildTitleField() {
    return CommonTextField(
      controller: _tituloController,
      label: 'Título *',
      hintText: 'Ej: Revisión línea 3',
      errorText: _tituloError,
      enabled: !_isSaving,
    );
  }

  /// Campo de comentario.
  Widget _buildCommentField() {
    return CommonMultilineTextField(
      controller: _comentarioController,
      hintText: 'Escribe aquí tu comentario...',
      errorText: _comentarioError,
      enabled: !_isSaving,
    );
  }

  /// Campo de autor (no editable).
  Widget _buildAuthorField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.small),
          child: Text(
            'Autor',
            style: AppTextStyles.label,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.medium,
            vertical: AppSpacing.medium,
          ),
          decoration: BoxDecoration(
            color: AppColors.cardBorder.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(
              color: AppColors.cardBorder,
              width: AppBorderWidth.thin,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.person,
                size: 20.0,
                color: AppColors.text.withOpacity(0.6),
              ),
              const SizedBox(width: AppSpacing.small),
              Text(
                widget.autorNombre,
                style: TextStyle(
                  fontSize: AppFontSizes.medium,
                  color: AppColors.text.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Botones de acción.
  Widget _buildButtons(BuildContext context, bool isEditing) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.text,
              side: BorderSide(
                color: AppColors.cardBorder,
                width: AppBorderWidth.normal,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.medium,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              ),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.lightText,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.medium,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              ),
            ),
            child: _isSaving
                ? SizedBox(
                    height: 20.0,
                    width: 20.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.lightText,
                      ),
                    ),
                  )
                : Text(isEditing ? 'Guardar' : 'Crear'),
          ),
        ),
      ],
    );
  }
}