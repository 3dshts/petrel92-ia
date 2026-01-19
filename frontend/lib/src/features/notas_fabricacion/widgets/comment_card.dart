// frontend/lib/src/features/fabricacion/widgets/comment_card.dart

import 'package:flutter/material.dart';
import '../../../core/models/calendar_comment_model.dart';
import '../../../core/theme/app_theme.dart';

/// Tarjeta que representa un comentario individual del calendario.
///
/// Muestra el título y el autor del comentario de forma compacta.
/// Es clickeable para abrir el detalle completo del comentario.
class CommentCard extends StatelessWidget {
  const CommentCard({
    super.key,
    required this.comment,
    required this.onTap,
  });

  /// Comentario a mostrar.
  final CalendarCommentModel comment;

  /// Callback ejecutado al hacer tap en la tarjeta.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.medium),
        margin: const EdgeInsets.only(bottom: AppSpacing.small),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          border: Border.all(
            color: AppColors.cardBorder,
            width: AppBorderWidth.thin,
          ),
        ),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: AppSpacing.medium),
            Expanded(child: _buildContent()),
            _buildArrowIcon(),
          ],
        ),
      ),
    );
  }

  /// Icono de comentario al inicio de la tarjeta.
  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.small),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
      ),
      child: Icon(
        Icons.comment,
        size: 20.0,
        color: AppColors.primary,
      ),
    );
  }

  /// Contenido principal: título y autor.
  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          comment.titulo,
          style: TextStyle(
            fontSize: AppFontSizes.medium,
            fontWeight: AppFontWeights.semiBold,
            color: AppColors.text,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4.0),
        Text(
          'Por: ${comment.autorNombre}',
          style: TextStyle(
            fontSize: AppFontSizes.small,
            color: AppColors.text.withOpacity(0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Icono de flecha al final de la tarjeta.
  Widget _buildArrowIcon() {
    return Icon(
      Icons.arrow_forward_ios,
      size: 16.0,
      color: AppColors.text.withOpacity(0.4),
    );
  }
}