// frontend/lib/src/features/fabricacion/widgets/calendar_widget.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/models/calendar_comment_model.dart';
import '../../../core/theme/app_theme.dart';

/// Widget de calendario visual que muestra los días del mes.
///
/// Características:
/// - Muestra mes actual con navegación entre meses
/// - Marca días con comentarios con fondo naranja
/// - Permite seleccionar un día
/// - Muestra tooltip con cantidad de comentarios en desktop (hover)
class CalendarWidget extends StatefulWidget {
  const CalendarWidget({
    super.key,
    required this.comments,
    required this.selectedDate,
    required this.focusedDay,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  /// Lista de todos los comentarios cargados.
  final List<CalendarCommentModel> comments;

  /// Fecha actualmente seleccionada.
  final DateTime selectedDate;

  /// Día actualmente enfocado en el calendario.
  final DateTime focusedDay;

  /// Callback cuando se selecciona una fecha.
  final Function(DateTime) onDateSelected;

  /// Callback cuando cambia el mes visible.
  final Function(DateTime) onMonthChanged;

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  /// Obtiene los comentarios de un día específico.
  List<CalendarCommentModel> _getCommentsForDay(DateTime day) {
    final dayString = _formatDate(day);
    return widget.comments
        .where((comment) => comment.fecha == dayString)
        .toList();
  }

  /// Formatea una fecha a YYYY-MM-DD.
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppBreakpoints.mobile;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(
          color: AppColors.cardBorder,
          width: AppBorderWidth.thin,
        ),
      ),
      child: TableCalendar(
        firstDay: DateTime(2020, 1, 1),
        lastDay: DateTime(2030, 12, 31),
        focusedDay: widget.focusedDay,
        selectedDayPredicate: (day) => isSameDay(widget.selectedDate, day),
        onDaySelected: _onDaySelected,
        onPageChanged: widget.onMonthChanged,
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableCalendarFormats: const {CalendarFormat.month: 'Mes'},

        // ============================================
        // ESTILOS Y CONFIGURACIÓN
        // ============================================
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: isMobile ? AppFontSizes.medium : AppFontSizes.large,
            fontWeight: AppFontWeights.bold,
            color: AppColors.primary,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: AppColors.primary,
            size: isMobile ? 24.0 : 28.0,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppColors.primary,
            size: isMobile ? 24.0 : 28.0,
          ),
          headerPadding: EdgeInsets.symmetric(
            vertical: isMobile ? AppSpacing.small : AppSpacing.medium,
          ),
        ),

        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: isMobile ? AppFontSizes.small : AppFontSizes.medium,
            fontWeight: AppFontWeights.semiBold,
            color: AppColors.text.withOpacity(0.7),
            height: 0.75,
          ),
          weekendStyle: TextStyle(
            fontSize: isMobile ? AppFontSizes.small : AppFontSizes.medium,
            fontWeight: AppFontWeights.semiBold,
            color: AppColors.text.withOpacity(0.7),
            height: 0.75
          ),
        ),

        calendarStyle: CalendarStyle(
          // Día actual (hoy)
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2.0),
          ),
          todayTextStyle: TextStyle(
            color: AppColors.primary,
            fontWeight: AppFontWeights.bold,
            fontSize: isMobile ? AppFontSizes.small : AppFontSizes.medium,
          ),

          // Día seleccionado
          selectedDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: TextStyle(
            color: AppColors.lightText,
            fontWeight: AppFontWeights.bold,
            fontSize: isMobile ? AppFontSizes.small : AppFontSizes.medium,
          ),

          // Días del mes actual
          defaultDecoration: BoxDecoration(shape: BoxShape.circle),
          defaultTextStyle: TextStyle(
            color: AppColors.text,
            fontSize: isMobile ? AppFontSizes.small : AppFontSizes.medium,
          ),

          // Días fuera del mes actual
          outsideDecoration: BoxDecoration(shape: BoxShape.circle),
          outsideTextStyle: TextStyle(
            color: AppColors.text.withOpacity(0.3),
            fontSize: isMobile ? AppFontSizes.small : AppFontSizes.medium,
          ),

          // Fin de semana
          weekendDecoration: BoxDecoration(shape: BoxShape.circle),
          weekendTextStyle: TextStyle(
            color: AppColors.text,
            fontSize: isMobile ? AppFontSizes.small : AppFontSizes.medium,
          ),

          // Marcadores de eventos
          markerDecoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          markerSize: 6.0,
          markersMaxCount: 1,
          markersAlignment: Alignment.bottomCenter,
          markerMargin: const EdgeInsets.only(top: 4.0),

          cellMargin: EdgeInsets.all(isMobile ? 4.0 : 8.0),
          cellPadding: EdgeInsets.zero,
        ),

        // ============================================
        // BUILDERS PERSONALIZADOS
        // ============================================
        calendarBuilders: CalendarBuilders(
          // Builder para días con comentarios
          defaultBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, false, isMobile);
          },

          // Builder para el día de hoy con comentarios
          todayBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, true, isMobile);
          },

          // Builder para días seleccionados con comentarios
          selectedBuilder: (context, day, focusedDay) {
            return _buildSelectedDayCell(day, isMobile);
          },
        ),
      ),
    );
  }

  /// Construye una celda de día normal o día actual.
  Widget _buildDayCell(DateTime day, bool isToday, bool isMobile) {
    final commentsForDay = _getCommentsForDay(day);
    final hasComments = commentsForDay.isNotEmpty;

    Widget dayCell = Container(
      margin: EdgeInsets.all(isMobile ? 4.0 : 8.0),
      decoration: BoxDecoration(
        color: hasComments
            ? AppColors.accent.withOpacity(0.2)
            : Colors.transparent,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(color: AppColors.primary, width: 2.0)
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: isToday ? AppColors.primary : AppColors.text,
                fontWeight: isToday
                    ? AppFontWeights.bold
                    : AppFontWeights.regular,
                fontSize: isMobile ? AppFontSizes.small : AppFontSizes.medium,
              ),
            ),
            if (hasComments)
              Container(
                margin: const EdgeInsets.only(top: 2.0),
                width: 6.0,
                height: 6.0,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );

    // Añadir tooltip en desktop si hay comentarios
    if (!isMobile && hasComments) {
      dayCell = Tooltip(
        message:
            '${commentsForDay.length} comentario${commentsForDay.length > 1 ? 's' : ''}',
        child: dayCell,
      );
    }

    return dayCell;
  }

  /// Construye una celda para el día seleccionado.
  Widget _buildSelectedDayCell(DateTime day, bool isMobile) {
    final commentsForDay = _getCommentsForDay(day);
    final hasComments = commentsForDay.isNotEmpty;

    Widget dayCell = Container(
      margin: EdgeInsets.all(isMobile ? 4.0 : 8.0),
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: AppColors.lightText,
                fontWeight: AppFontWeights.bold,
                fontSize: isMobile ? AppFontSizes.small : AppFontSizes.medium,
              ),
            ),
            if (hasComments)
              Container(
                margin: const EdgeInsets.only(top: 2.0),
                width: 6.0,
                height: 6.0,
                decoration: BoxDecoration(
                  color: AppColors.lightText,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );

    // Añadir tooltip en desktop si hay comentarios
    if (!isMobile && hasComments) {
      dayCell = Tooltip(
        message:
            '${commentsForDay.length} comentario${commentsForDay.length > 1 ? 's' : ''}',
        child: dayCell,
      );
    }

    return dayCell;
  }

  /// Maneja la selección de un día.
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    widget.onDateSelected(selectedDay);
  }
}
