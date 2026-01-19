// frontend/lib/src/features/fabricacion/widgets/comment_detail_dialog.dart

import 'package:flutter/material.dart';
import '../../../core/models/calendar_comment_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/common_widgets/confirmation_dialog.dart';
import 'package:intl/intl.dart';


/// Muestra el dialog de detalle de un comentario.
Future<void> showCommentDetailDialog({
  required BuildContext context,
  required CalendarCommentModel comment,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  return showDialog(
    context: context,
    builder: (context) => CommentDetailDialog(
      comment: comment,
      onEdit: onEdit,
      onDelete: onDelete,
    ),
  );
}

/// Dialog que muestra el detalle completo de un comentario.
///
/// Incluye botones para:
/// - Editar el comentario
/// - Eliminar el comentario (con confirmación)
class CommentDetailDialog extends StatelessWidget {
  const CommentDetailDialog({
    super.key,
    required this.comment,
    required this.onEdit,
    required this.onDelete,
  });

  /// Comentario a mostrar.
  final CalendarCommentModel comment;

  /// Callback para editar el comentario.
  final VoidCallback onEdit;

  /// Callback para eliminar el comentario.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppBreakpoints.mobile;

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
                _buildHeader(context),
                const SizedBox(height: AppSpacing.large),
                _buildMetadata(),
                const SizedBox(height: AppSpacing.large),
                _buildTitle(),
                const SizedBox(height: AppSpacing.medium),
                _buildComment(),
                const SizedBox(height: AppSpacing.xl),
                _buildDeleteButton(context),
                const SizedBox(height: AppSpacing.medium),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Header del dialog.
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.small),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.small),
          ),
          child: Icon(
            Icons.comment,
            color: AppColors.primary,
            size: 24.0,
          ),
        ),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: Text(
            'Detalle del Comentario',
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

  /// Metadata (fecha, autor, creación).
  Widget _buildMetadata() {
    final fecha = DateFormat('dd/MM/yyyy').format(
      DateTime.parse(comment.fecha),
    );
    final fechaCreacion = DateFormat('dd/MM/yyyy HH:mm').format(
      DateTime.parse(comment.fechaCreacion),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(
          color: AppColors.cardBorder,
          width: AppBorderWidth.thin,
        ),
      ),
      child: Column(
        children: [
          _buildMetadataRow(Icons.calendar_today, 'Fecha', fecha),
          const SizedBox(height: AppSpacing.small),
          _buildMetadataRow(Icons.person, 'Autor', comment.autorNombre),
          const SizedBox(height: AppSpacing.small),
          _buildMetadataRow(Icons.access_time, 'Creado', fechaCreacion),
          if (comment.fechaModificacion != null) ...[
            const SizedBox(height: AppSpacing.small),
            _buildMetadataRow(
              Icons.edit,
              'Modificado',
              DateFormat('dd/MM/yyyy HH:mm').format(
                DateTime.parse(comment.fechaModificacion!),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Fila de metadata.
  Widget _buildMetadataRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.0,
          color: AppColors.text.withOpacity(0.6),
        ),
        const SizedBox(width: AppSpacing.small),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: AppFontSizes.small,
            fontWeight: AppFontWeights.semiBold,
            color: AppColors.text.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: AppSpacing.small),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: AppFontSizes.small,
              color: AppColors.text,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  /// Título del comentario.
  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Título',
          style: TextStyle(
            fontSize: AppFontSizes.small,
            fontWeight: AppFontWeights.semiBold,
            color: AppColors.text.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          comment.titulo,
          style: TextStyle(
            fontSize: AppFontSizes.large,
            fontWeight: AppFontWeights.bold,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  /// Comentario completo.
  Widget _buildComment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comentario',
          style: TextStyle(
            fontSize: AppFontSizes.small,
            fontWeight: AppFontWeights.semiBold,
            color: AppColors.text.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.medium),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(
              color: AppColors.cardBorder,
              width: AppBorderWidth.thin,
            ),
          ),
          child: Text(
            comment.comentario,
            style: TextStyle(
              fontSize: AppFontSizes.medium,
              color: AppColors.text,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  /// Botón de eliminar (destructivo).
  Widget _buildDeleteButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _handleDelete(context),
      icon: const Icon(Icons.delete),
      label: const Text('Eliminar Comentario'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: BorderSide(
          color: AppColors.error,
          width: AppBorderWidth.normal,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.medium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        ),
      ),
    );
  }

  /// Botones de cerrar y editar.
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
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
            child: const Text('Cerrar'),
          ),
        ),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onEdit();
            },
            icon: const Icon(Icons.edit),
            label: const Text('Editar'),
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
          ),
        ),
      ],
    );
  }

  /// Maneja la eliminación con confirmación.
  void _handleDelete(BuildContext context) {
    ConfirmationDialog.show(
      context: context,
      title: '¿Eliminar comentario?',
      message: 'Esta acción no se puede deshacer. El comentario se eliminará permanentemente.',
      confirmText: 'Eliminar',
      confirmColor: AppColors.error,
      icon: Icons.delete_forever,
      onConfirm: () {
        Navigator.of(context).pop(); // Cerrar el dialog de detalle
        onDelete();
      },
    );
  }
}