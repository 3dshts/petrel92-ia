// frontend/lib/src/features/fabricacion/widgets/day_comments_list.dart

import 'package:flutter/material.dart';
import '../../../core/models/calendar_comment_model.dart';
import '../../../core/theme/app_theme.dart';
import 'comment_card.dart';
import 'package:intl/intl.dart';

/// Lista de comentarios para un día específico del calendario.
///
/// Muestra:
/// - Header con la fecha del día seleccionado
/// - Lista de comentarios del día (si hay)
/// - Botón para añadir nuevo comentario
/// - Mensaje si no hay comentarios
class DayCommentsList extends StatelessWidget {
  const DayCommentsList({
    super.key,
    required this.selectedDate,
    required this.comments,
    required this.onCommentTap,
    required this.onAddComment,
  });

  /// Fecha del día seleccionado.
  final DateTime selectedDate;

  /// Lista de comentarios del día seleccionado.
  final List<CalendarCommentModel> comments;

  /// Callback cuando se hace tap en un comentario.
  final Function(CalendarCommentModel) onCommentTap;

  /// Callback cuando se presiona el botón de añadir comentario.
  final VoidCallback onAddComment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: AppSpacing.medium),
        if (comments.isEmpty)
          _buildEmptyState()
        else
          _buildCommentsList(),
        const SizedBox(height: AppSpacing.medium),
        _buildAddButton(),
      ],
    );
  }

  /// Header con la fecha del día seleccionado.
  Widget _buildHeader() {
    final formattedDate = DateFormat('d \'de\' MMMM \'de\' yyyy', 'es_ES')
        .format(selectedDate);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 20.0,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Text(
              formattedDate,
              style: TextStyle(
                fontSize: AppFontSizes.medium,
                fontWeight: AppFontWeights.semiBold,
                color: AppColors.primary,
              ),
            ),
          ),
          if (comments.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.small,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
              child: Text(
                '${comments.length}',
                style: TextStyle(
                  fontSize: AppFontSizes.small,
                  fontWeight: AppFontWeights.bold,
                  color: AppColors.lightText,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Estado vacío cuando no hay comentarios.
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.comment_outlined,
            size: 48.0,
            color: AppColors.text.withOpacity(0.3),
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'Sin comentarios para este día',
            style: TextStyle(
              fontSize: AppFontSizes.medium,
              color: AppColors.text.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Lista de comentarios.
  Widget _buildCommentsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return CommentCard(
          comment: comment,
          onTap: () => onCommentTap(comment),
        );
      },
    );
  }

  /// Botón para añadir nuevo comentario.
  Widget _buildAddButton() {
    return OutlinedButton.icon(
      onPressed: onAddComment,
      icon: const Icon(Icons.add),
      label: const Text('Añadir Comentario'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(
          color: AppColors.primary,
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
}