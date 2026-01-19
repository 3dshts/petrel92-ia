// frontend/lib/src/features/fabricacion/widgets/calendar_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/calendar_comment_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/calendar/calendar_cubit.dart';
import '../../../core/calendar/calendar_state.dart';
import 'calendar_widget.dart';
import 'day_comments_list.dart';
import 'comment_form_dialog.dart';
import 'comment_detail_dialog.dart';

/// Muestra el BottomSheet del calendario.
/// Muestra el BottomSheet del calendario.
Future<void> showCalendarBottomSheet({
  required BuildContext context,
  required CalendarCubit calendarCubit,  // ← NUEVO parámetro
  required String autorNombre,
  required String autorId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BlocProvider.value(  // ← CAMBIO: usar .value en lugar de crear uno nuevo
      value: calendarCubit,  // ← Pasar el cubit existente
      child: CalendarBottomSheet(
        autorNombre: autorNombre,
        autorId: autorId,
      ),
    ),
  );
}

/// BottomSheet que muestra el calendario y comentarios.
///
/// Diseñado para móvil. Se abre desde abajo
/// ocupando aproximadamente el 90% de la altura de pantalla.
///
/// Contenido:
/// - Header con título y botón cerrar
/// - CalendarWidget (calendario visual)
/// - DayCommentsList (comentarios del día seleccionado)
class CalendarBottomSheet extends StatefulWidget {
  const CalendarBottomSheet({
    super.key,
    required this.autorNombre,
    required this.autorId,
  });

  /// Nombre completo del usuario actual.
  final String autorNombre;

  /// ID del usuario actual.
  final String autorId;

  @override
  State<CalendarBottomSheet> createState() => _CalendarBottomSheetState();
}

class _CalendarBottomSheetState extends State<CalendarBottomSheet> {
  late DateTime _selectedDate;
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _focusedMonth = DateTime.now();
    
    // Cargar comentarios del mes actual
    _loadCommentsForMonth(_selectedDate);
  }

  /// Carga comentarios de un mes específico.
  void _loadCommentsForMonth(DateTime month) {
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);

    final startDateStr = _formatDate(startDate);
    final endDateStr = _formatDate(endDate);

    context.read<CalendarCubit>().loadComments(
      startDate: startDateStr,
      endDate: endDateStr,
    );
  }

  /// Formatea una fecha a YYYY-MM-DD.
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Obtiene los comentarios del día seleccionado.
  List<CalendarCommentModel> _getCommentsForSelectedDay(
    List<CalendarCommentModel> allComments,
  ) {
    final selectedDateStr = _formatDate(_selectedDate);
    return allComments
        .where((comment) => comment.fecha == selectedDateStr)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppBorderRadius.large),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10.0,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildDragHandle(),
              _buildHeader(),
              Expanded(
                child: BlocBuilder<CalendarCubit, CalendarState>(
                  builder: (context, state) {
                    if (state is CalendarLoading) {
                      return _buildLoadingState();
                    }

                    if (state is CalendarError) {
                      return _buildErrorState(state.message);
                    }

                    if (state is CalendarLoaded) {
                      return _buildLoadedState(
                        state.comments,
                        scrollController,
                      );
                    }

                    return _buildInitialState();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Handle para arrastrar el bottom sheet.
  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.small),
      width: 40.0,
      height: 4.0,
      decoration: BoxDecoration(
        color: AppColors.cardBorder,
        borderRadius: BorderRadius.circular(2.0),
      ),
    );
  }

  /// Header del bottom sheet con título y botón cerrar.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.cardBorder,
            width: AppBorderWidth.thin,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.primary,
            ),
            tooltip: 'Volver',
          ),
          const SizedBox(width: AppSpacing.small),
          Icon(
            Icons.calendar_month,
            color: AppColors.primary,
            size: 24.0,
          ),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Text(
              'Calendario',
              style: TextStyle(
                fontSize: AppFontSizes.large,
                fontWeight: AppFontWeights.bold,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Estado inicial (sin datos cargados).
  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 48.0,
            color: AppColors.text.withOpacity(0.3),
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'Cargando calendario...',
            style: TextStyle(
              fontSize: AppFontSizes.medium,
              color: AppColors.text.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Estado de carga.
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'Cargando...',
            style: TextStyle(
              fontSize: AppFontSizes.medium,
              color: AppColors.text.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Estado de error.
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.0,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'Error',
              style: TextStyle(
                fontSize: AppFontSizes.large,
                fontWeight: AppFontWeights.bold,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              message,
              style: TextStyle(
                fontSize: AppFontSizes.medium,
                color: AppColors.text.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.medium),
            ElevatedButton.icon(
              onPressed: () => _loadCommentsForMonth(_selectedDate),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado con datos cargados.
  Widget _buildLoadedState(
    List<CalendarCommentModel> allComments,
    ScrollController scrollController,
  ) {
    final commentsForSelectedDay = _getCommentsForSelectedDay(allComments);

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Calendario visual
          CalendarWidget(
            comments: allComments,
            selectedDate: _selectedDate,
            focusedDay: _focusedMonth,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
                _focusedMonth = date; // <-- Actualiza el mes visible
              });
            },
            onMonthChanged: (month) {
              setState(() => _focusedMonth = month);
              _loadCommentsForMonth(month);
            },
          ),
          const SizedBox(height: AppSpacing.large),
          const Divider(
            color: AppColors.cardBorder,
            thickness: AppBorderWidth.thin,
          ),
          const SizedBox(height: AppSpacing.medium),
          // Lista de comentarios del día
          DayCommentsList(
            selectedDate: _selectedDate,
            comments: commentsForSelectedDay,
            onCommentTap: (comment) => _showCommentDetail(comment),
            onAddComment: () => _showAddCommentDialog(),
          ),
        ],
      ),
    );
  }

  // ============================================
  // MÉTODOS DE NAVEGACIÓN A DIALOGS
  // ============================================

  /// Muestra el dialog de detalle de un comentario.
  void _showCommentDetail(CalendarCommentModel comment) {
    showCommentDetailDialog(
      context: context,
      comment: comment,
      onEdit: () => _showEditCommentDialog(comment),
      onDelete: () => _handleDeleteComment(comment.id),
    );
  }

  /// Muestra el dialog para añadir un nuevo comentario.
  void _showAddCommentDialog() {
    showCommentFormDialog(
      context: context,
      selectedDate: _selectedDate,
      autorNombre: widget.autorNombre,
      onSave: (titulo, comentario) async {
        await context.read<CalendarCubit>().createComment(
          fecha: _formatDate(_selectedDate),
          titulo: titulo,
          comentario: comentario,
          autorId: widget.autorId,
          autorNombre: widget.autorNombre,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comentario creado exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
    );
  }

  /// Muestra el dialog para editar un comentario existente.
  void _showEditCommentDialog(CalendarCommentModel comment) {
    showCommentFormDialog(
      context: context,
      selectedDate: DateTime.parse(comment.fecha),
      autorNombre: widget.autorNombre,
      commentToEdit: comment,
      onSave: (titulo, comentario) async {
        await context.read<CalendarCubit>().updateComment(
          eventId: comment.id,
          titulo: titulo,
          comentario: comentario,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comentario actualizado exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
    );
  }

  /// Elimina un comentario.
  Future<void> _handleDeleteComment(String eventId) async {
    await context.read<CalendarCubit>().deleteComment(eventId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comentario eliminado exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}