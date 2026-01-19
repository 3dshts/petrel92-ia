// frontend/lib/src/features/fabricacion/widgets/calendar_drawer.dart

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

/// Drawer lateral que muestra el calendario y comentarios.
///
/// Diseñado para desktop/tablet. Se abre desde la derecha
/// ocupando aproximadamente el 30% del ancho de pantalla.
class CalendarDrawer extends StatefulWidget {
  const CalendarDrawer({
    super.key,
    required this.onClose,
    required this.autorNombre,
    required this.autorId,
  });

  final VoidCallback onClose;
  final String autorNombre;
  final String autorId;

  @override
  State<CalendarDrawer> createState() => _CalendarDrawerState();
}

class _CalendarDrawerState extends State<CalendarDrawer> {
  late DateTime _selectedDate;
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _focusedMonth = DateTime.now();

    // Cargar comentarios del mes actual
    _loadCommentsForMonth(DateTime.now());
  }

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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

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
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.0,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
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
                  return _buildLoadedState(state.comments);
                }

                return _buildInitialState();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month, color: AppColors.lightText, size: 28.0),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Text(
              'Calendario',
              style: TextStyle(
                fontSize: AppFontSizes.large,
                fontWeight: AppFontWeights.bold,
                color: AppColors.lightText,
              ),
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: Icon(Icons.close, color: AppColors.lightText),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.0, color: AppColors.error),
            const SizedBox(height: AppSpacing.large),
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
            const SizedBox(height: AppSpacing.large),
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

  Widget _buildLoadedState(List<CalendarCommentModel> allComments) {
    final commentsForSelectedDay = _getCommentsForSelectedDay(allComments);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CalendarWidget(
            key: ValueKey('calendar-${allComments.hashCode}'),
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
          const SizedBox(height: AppSpacing.xl),
          const Divider(
            color: AppColors.cardBorder,
            thickness: AppBorderWidth.thin,
          ),
          const SizedBox(height: AppSpacing.large),
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

  void _showCommentDetail(CalendarCommentModel comment) {
    showCommentDetailDialog(
      context: context,
      comment: comment,
      onEdit: () => _showEditCommentDialog(comment),
      onDelete: () => _handleDeleteComment(comment.id),
    );
  }

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
